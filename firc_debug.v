module firc(
  input Clk,
  input Reset,
  input PushIn,
  output StopIn,
  input [23:0] SampI,
  input [23:0] SampQ,
  input PushCoef,
  input [4:0] CoefAddr,
  input [26:0] CoefI,
  input [26:0] CoefQ,
  output PushOut,
  output [31:0] FI,
  output [31:0] FQ
  );
  reg PushOut_d;
  reg [31:0] FI_d, FQ_d;


  // Coefficient Memory
  reg [26:0] CoefIMem [15:0];
  reg [26:0] CoefQMem [15:0];

  //Sample Memory
  reg signed [23:0] SampIMem [28:0];
  reg signed [23:0] SampQMem [28:0];

  assign PushOut = PushOut_d;
  assign FI = FI_d;
  assign FQ = FQ_d;

  assign StopIn = 0;

  //Samples
  always@(posedge(Clk) or posedge(Reset))begin
    if(Reset)begin
      //Resets Sample Registers
      for(int i=0;i<29;i+=1)begin
        SampIMem[i] <= 24'b0; 
        SampQMem[i] <= 24'b0; 
     end
    end
    // Storing Samples, incorrect condition for now
    else if(PushIn==1) begin
      SampIMem <= {SampIMem[27:0],SampI}; 
      SampQMem <= {SampQMem[27:0],SampQ}; 
    end
  end


  //Coefficients
  always@(posedge(Clk) or posedge(Reset))begin
    if(Reset)begin
      //Resets Coefficients
      for(int i=0;i<16;i+=1)begin
        CoefIMem[i] <= 27'b0; 
        CoefQMem[i] <= 27'b0; 
     end
    end
    //Stores Coefficients
    else if(PushCoef==1)begin
      CoefIMem[CoefAddr] = CoefI;
      CoefQMem[CoefAddr] = CoefQ;
      
    end

  end


  always@(posedge(Clk))begin
  if (CoefAddr == 5'h1f) begin
     PushOut_d <= 1;
     FI_d <= 0;
     FQ_d <= 0;
  end
  else begin
     PushOut_d <= 0;
     FI_d <= 0;
     FQ_d <= 0;
  end


     // displaying inputs
     $display("Reset: %h", Reset);
     $display("SampI: %h", SampI);
     $display("SampQ: %h", SampQ);
     $display("PushCoef: %h", PushCoef);
     $display("CoefAddr: %h", CoefAddr);
     $display("CoefI: %h", CoefI);
     $display("CoefQ: %h", CoefQ);
     $display("PushIn: %h \n", PushIn);


     DisplayCoefs(CoefIMem, CoefQMem);
     DisplaySamps(SampIMem,SampQMem);
  end  

  task DisplayCoefs;
     input [26:0] CoefI [15:0];
     input [26:0] CoefQ [15:0];
     for(int i=0;i<16;i+=1)begin
       $display("CoefIMem: %h, Index: %h", CoefI[i], i);
       $display("CoefQMem: %h, Index: %h", CoefQ[i], i);
     end
  endtask

  task DisplaySamps;
     input signed[23:0] SampI [28:0];
     input signed[23:0] SampQ [28:0];
     for(int i=0;i<29;i+=1)begin
       $display("SampIMem: %h, Index: %h", SampI[i], i);
       $display("SampQMem: %h, Index: %h", SampQ[i], i);
     end
  endtask


endmodule
