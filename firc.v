///////////////////////////////////////////////////////////////////////////////
// Module : firc
//
// 29 Tap FIR FILTER.
// EE287 SP23 project
///////////////////////////////////////////////////////////////////////////////

module firc (input  wire               Clk,
             input  wire               Reset,
             input  wire               PushIn,
             output wire               StopIn,
             input  reg  signed [23:0] SampI,
             input  reg  signed [23:0] SampQ,
             input                     PushCoef,
             input  reg  signed [4:0]  CoefAddr,
             input  reg  signed [26:0] CoefI,
             input  reg  signed [26:0] CoefQ,
             output wire               PushOut,
             output wire        [31:0] FI,
             output wire        [31:0] FQ);


  // Wires and regs
  // Sample regs
  reg signed [23:0] shift_reg_i[28:0];
  reg signed [23:0] shift_reg_q[28:0];

  reg signed [23:0] data_i_0_loc_a, data_i_1_loc_a, data_i_2_loc_a,  data_i_3_loc_a, data_i_4_loc_a;
  reg signed [23:0] data_q_0_loc_a, data_q_1_loc_a, data_q_2_loc_a,  data_q_3_loc_a, data_q_4_loc_a;
  reg signed [23:0] data_i_0_loc_b, data_i_1_loc_b, data_i_2_loc_b,  data_i_3_loc_b, data_i_4_loc_b;
  reg signed [23:0] data_q_0_loc_b, data_q_1_loc_b, data_q_2_loc_b,  data_q_3_loc_b, data_q_4_loc_b;

  // Coefficient regs
  reg [26:0] CoefIMem [15:0];
  reg [26:0] CoefQMem [15:0];

  reg [26:0] i_coef_reg1, i_coef_reg2, i_coef_reg3, i_coef_reg4, i_coef_reg5;
  reg [26:0] q_coef_reg1, q_coef_reg2, q_coef_reg3, q_coef_reg4, q_coef_reg5;
  reg [26:0] i_coef_reg1_d, i_coef_reg2_d, i_coef_reg3_d, i_coef_reg4_d, i_coef_reg5_d;
  reg [26:0] q_coef_reg1_d, q_coef_reg2_d, q_coef_reg3_d, q_coef_reg4_d, q_coef_reg5_d;

  wire signed [23:0] shift_reg_i_0;
  wire signed [23:0] shift_reg_q_0;

  reg [23:0] a2m_i_0, a2m_i_1, a2m_i_2, a2m_i_3, a2m_i_4;
  reg [23:0] a2m_q_0, a2m_q_1, a2m_q_2, a2m_q_3, a2m_q_4;

  reg fifo_rd_en;
  wire fifo_empty;

  // STATE PARAMETERS
  parameter ST_RESET = 2'b00, ST_MUL_0 = 2'b01, ST_MUL_1 = 2'b10, ST_MUL_2 = 2'b11;
  reg [1:0] curr_state, next_state;

  // Module assignments

  // DA_TODO
  // Assign output wire
  // assign PushOut = ;
  // assign FI = ;
  // assign FQ = ;


  // Module Instances
  fifo ip_fifo(.clk(Clk), .rst(Reset), .rd(fifo_rd_en), .wr(PushIn), .write_data1(SampI), .write_data2(SampQ), .empty(fifo_empty), .full(StopIn), .read_data1(shift_reg_i_0), .read_data2(shift_reg_q_0));

  pre_mult_adder pre_add_0 (.clk(Clk), .reset(Reset), .a_i(data_i_0_loc_a), .a_q(data_q_0_loc_a), .b_i(data_i_0_loc_b), .b_q(data_q_0_loc_b), .o_i(a2m_i_0), .o_q(a2m_q_0));
  pre_mult_adder pre_add_1 (.clk(Clk), .reset(Reset), .a_i(data_i_1_loc_a), .a_q(data_q_1_loc_a), .b_i(data_i_1_loc_b), .b_q(data_q_1_loc_b), .o_i(a2m_i_1), .o_q(a2m_q_1));
  pre_mult_adder pre_add_2 (.clk(Clk), .reset(Reset), .a_i(data_i_2_loc_a), .a_q(data_q_2_loc_a), .b_i(data_i_2_loc_b), .b_q(data_q_2_loc_b), .o_i(a2m_i_2), .o_q(a2m_q_2));
  pre_mult_adder pre_add_3 (.clk(Clk), .reset(Reset), .a_i(data_i_3_loc_a), .a_q(data_q_3_loc_a), .b_i(data_i_3_loc_b), .b_q(data_q_3_loc_b), .o_i(a2m_i_3), .o_q(a2m_q_3));
  pre_mult_adder pre_add_4 (.clk(Clk), .reset(Reset), .a_i(data_i_4_loc_a), .a_q(data_q_4_loc_a), .b_i(data_i_4_loc_b), .b_q(data_q_4_loc_b), .o_i(a2m_i_4), .o_q(a2m_q_4));

  ComplexMult cm_0(.clk(Clk), .reset(Reset), .data_i(a2m_i_0), .data_q(a2m_q_0), .coef_i(i_coef_reg1), .coef_q(q_coef_reg1), .mult_out_i(), .mult_out_q());
  ComplexMult cm_1(.clk(Clk), .reset(Reset), .data_i(a2m_i_1), .data_q(a2m_q_1), .coef_i(i_coef_reg2), .coef_q(q_coef_reg2), .mult_out_i(), .mult_out_q());
  ComplexMult cm_2(.clk(Clk), .reset(Reset), .data_i(a2m_i_2), .data_q(a2m_q_2), .coef_i(i_coef_reg3), .coef_q(q_coef_reg3), .mult_out_i(), .mult_out_q());
  ComplexMult cm_3(.clk(Clk), .reset(Reset), .data_i(a2m_i_3), .data_q(a2m_q_3), .coef_i(i_coef_reg4), .coef_q(q_coef_reg4), .mult_out_i(), .mult_out_q());
  ComplexMult cm_4(.clk(Clk), .reset(Reset), .data_i(a2m_i_4), .data_q(a2m_q_4), .coef_i(i_coef_reg5), .coef_q(q_coef_reg5), .mult_out_i(), .mult_out_q());

  //Coefficient Handling
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
      CoefIMem[CoefAddr] <= CoefI;
      CoefQMem[CoefAddr] <= CoefQ;
    end
  end

  // Sample Handling
  always@(posedge(Clk) or posedge(Reset))
  begin
    if(Reset)
    begin
      //Resets Sample Registers
      for(int i=0;i<29;i+=1)
      begin
        shift_reg_i[i] <= 24'b0;
        shift_reg_q[i] <= 24'b0;
      end
    end
    // Storing Samples
    else if(curr_state == ST_MUL_0 && fifo_empty == 0)
    begin
      shift_reg_i <= {shift_reg_i[27:0], shift_reg_i_0};
      shift_reg_q <= {shift_reg_q[27:0], shift_reg_q_0};
    end
  end

  //State Machine
  always @ (posedge Clk or posedge Reset)
  begin
    if(Reset)
    begin
      curr_state <= ST_RESET;

      i_coef_reg1 <=0;
      i_coef_reg2 <=0;
      i_coef_reg3 <=0;
      i_coef_reg4 <=0;
      i_coef_reg5 <=0;

      q_coef_reg1 <=0;
      q_coef_reg2 <=0;
      q_coef_reg3 <=0;
      q_coef_reg4 <=0;
      q_coef_reg5 <=0;
    end
    else
    begin
      curr_state <= next_state;

      i_coef_reg1 <=i_coef_reg1_d;
      i_coef_reg2 <=i_coef_reg2_d;
      i_coef_reg3 <=i_coef_reg3_d;
      i_coef_reg4 <=i_coef_reg4_d;
      i_coef_reg5 <=i_coef_reg5_d;

      q_coef_reg1 <=q_coef_reg1_d;
      q_coef_reg2 <=q_coef_reg2_d;
      q_coef_reg3 <=q_coef_reg3_d;
      q_coef_reg4 <=q_coef_reg4_d;
      q_coef_reg5 <=q_coef_reg5_d;
    end
  end

  always @ (*)
  begin
    case(curr_state)
      ST_RESET :
      begin
        i_coef_reg1_d = 0;
        i_coef_reg2_d = 0;
        i_coef_reg3_d = 0;
        i_coef_reg4_d = 0;
        i_coef_reg5_d = 0;

        q_coef_reg1_d = 0;
        q_coef_reg2_d = 0;
        q_coef_reg3_d = 0;
        q_coef_reg4_d = 0;
        q_coef_reg5_d = 0;

        data_i_0_loc_a = 0;
        data_i_1_loc_a = 0;
        data_i_2_loc_a = 0;
        data_i_3_loc_a = 0;
        data_i_4_loc_a = 0;

        data_q_0_loc_a = 0;
        data_q_1_loc_a = 0;
        data_q_2_loc_a = 0;
        data_q_3_loc_a = 0;
        data_q_4_loc_a = 0;

        data_i_0_loc_b = 0;
        data_i_1_loc_b = 0;
        data_i_2_loc_b = 0;
        data_i_3_loc_b = 0;
        data_i_4_loc_b = 0;

        data_q_0_loc_b = 0;
        data_q_1_loc_b = 0;
        data_q_2_loc_b = 0;
        data_q_3_loc_b = 0;
        data_q_4_loc_b = 0;

        fifo_rd_en = 0;

        next_state = ST_MUL_0;
      end
      ST_MUL_0 :
      begin
        i_coef_reg1_d = CoefIMem[0];
        i_coef_reg2_d = CoefIMem[1];
        i_coef_reg3_d = CoefIMem[2];
        i_coef_reg4_d = CoefIMem[3];
        i_coef_reg5_d = CoefIMem[4];

        q_coef_reg1_d = CoefQMem[0];
        q_coef_reg2_d = CoefQMem[1];
        q_coef_reg3_d = CoefQMem[2];
        q_coef_reg4_d = CoefQMem[3];
        q_coef_reg5_d = CoefQMem[4];

        if(fifo_empty)
        begin
          data_i_0_loc_a = 0;
          data_i_1_loc_a = 0;
          data_i_2_loc_a = 0;
          data_i_3_loc_a = 0;
          data_i_4_loc_a = 0;

          data_q_0_loc_a = 0;
          data_q_1_loc_a = 0;
          data_q_2_loc_a = 0;
          data_q_3_loc_a = 0;
          data_q_4_loc_a = 0;

          data_i_0_loc_b = 0;
          data_i_1_loc_b = 0;
          data_i_2_loc_b = 0;
          data_i_3_loc_b = 0;
          data_i_4_loc_b = 0;

          data_q_0_loc_b = 0;
          data_q_1_loc_b = 0;
          data_q_2_loc_b = 0;
          data_q_3_loc_b = 0;
          data_q_4_loc_b = 0;

          fifo_rd_en = 0;

          next_state = ST_MUL_0;
        end
        else
        begin
          data_i_0_loc_a = shift_reg_i[0];
          data_i_1_loc_a = shift_reg_i[1];
          data_i_2_loc_a = shift_reg_i[2];
          data_i_3_loc_a = shift_reg_i[3];
          data_i_4_loc_a = shift_reg_i[4];

          data_q_0_loc_a = shift_reg_q[28];
          data_q_1_loc_a = shift_reg_q[27];
          data_q_2_loc_a = shift_reg_q[26];
          data_q_3_loc_a = shift_reg_q[25];
          data_q_4_loc_a = shift_reg_q[24];

          data_i_0_loc_b = shift_reg_i[0];
          data_i_1_loc_b = shift_reg_i[1];
          data_i_2_loc_b = shift_reg_i[2];
          data_i_3_loc_b = shift_reg_i[3];
          data_i_4_loc_b = shift_reg_i[4];
                                         
          data_q_0_loc_b = shift_reg_q[28];
          data_q_1_loc_b = shift_reg_q[27];
          data_q_2_loc_b = shift_reg_q[26];
          data_q_3_loc_b = shift_reg_q[25];
          data_q_4_loc_b = shift_reg_q[24];

          fifo_rd_en = 1;

          next_state = ST_MUL_1;
        end
      end
      ST_MUL_1 :
      begin
        i_coef_reg1_d = CoefIMem[5];
        i_coef_reg2_d = CoefIMem[6];
        i_coef_reg3_d = CoefIMem[7];
        i_coef_reg4_d = CoefIMem[8];
        i_coef_reg5_d = CoefIMem[9];

        q_coef_reg1_d = CoefQMem[5];
        q_coef_reg2_d = CoefQMem[6];
        q_coef_reg3_d = CoefQMem[7];
        q_coef_reg4_d = CoefQMem[8];
        q_coef_reg5_d = CoefQMem[9];

        data_i_0_loc_a = shift_reg_i[5];
        data_i_1_loc_a = shift_reg_i[6];
        data_i_2_loc_a = shift_reg_i[7];
        data_i_3_loc_a = shift_reg_i[8];
        data_i_4_loc_a = shift_reg_i[9];

        data_q_0_loc_a = shift_reg_q[23];
        data_q_1_loc_a = shift_reg_q[22];
        data_q_2_loc_a = shift_reg_q[21];
        data_q_3_loc_a = shift_reg_q[20];
        data_q_4_loc_a = shift_reg_q[19];

        data_i_0_loc_b = shift_reg_i[5];
        data_i_1_loc_b = shift_reg_i[6];
        data_i_2_loc_b = shift_reg_i[7];
        data_i_3_loc_b = shift_reg_i[8];
        data_i_4_loc_b = shift_reg_i[9];
                                       
        data_q_0_loc_b = shift_reg_q[23];
        data_q_1_loc_b = shift_reg_q[22];
        data_q_2_loc_b = shift_reg_q[21];
        data_q_3_loc_b = shift_reg_q[20];
        data_q_4_loc_b = shift_reg_q[19];

        fifo_rd_en = 0;

        next_state = ST_MUL_2;
      end
      ST_MUL_2 :
      begin
        i_coef_reg1_d = CoefIMem[10];
        i_coef_reg2_d = CoefIMem[11];
        i_coef_reg3_d = CoefIMem[12];
        i_coef_reg4_d = CoefIMem[13];
        i_coef_reg5_d = CoefIMem[14];

        q_coef_reg1_d = CoefQMem[10];
        q_coef_reg2_d = CoefQMem[11];
        q_coef_reg3_d = CoefQMem[12];
        q_coef_reg4_d = CoefQMem[13];
        q_coef_reg5_d = CoefQMem[14];

        data_i_0_loc_a = shift_reg_i[10];
        data_i_1_loc_a = shift_reg_i[11];
        data_i_2_loc_a = shift_reg_i[12];
        data_i_3_loc_a = shift_reg_i[13];
        data_i_4_loc_a = shift_reg_i[14];

        data_q_0_loc_a = shift_reg_q[18];
        data_q_1_loc_a = shift_reg_q[17];
        data_q_2_loc_a = shift_reg_q[16];
        data_q_3_loc_a = shift_reg_q[15];
        data_q_4_loc_a = shift_reg_q[14];

        data_i_0_loc_b = shift_reg_i[10];
        data_i_1_loc_b = shift_reg_i[11];
        data_i_2_loc_b = shift_reg_i[12];
        data_i_3_loc_b = shift_reg_i[13];
        data_i_4_loc_b = 24'b0;
                                       
        data_q_0_loc_b = shift_reg_q[18];
        data_q_1_loc_b = shift_reg_q[17];
        data_q_2_loc_b = shift_reg_q[16];
        data_q_3_loc_b = shift_reg_q[15];
        data_q_4_loc_b =24'b0;

        fifo_rd_en = 0;

        next_state = ST_MUL_0;
      end
    endcase
  end

endmodule

///////////////////////////////////////////////////////////////////////////////
// Module : fifo
// Parameters : DWIDTH
//
// FIFO of word size 24 bits. Accepts/Puts Real and Imag part together in a clk
// cycle. FiFO depth fixed to 4.
///////////////////////////////////////////////////////////////////////////////
module fifo #(parameter DWIDTH=24)
(
    input wire clk,
    input wire rst,
    input wire rd,
    input wire wr,
    input wire [DWIDTH-1:0] write_data1,
    input wire [DWIDTH-1:0] write_data2,
    output wire empty,
    output wire full,
    output wire [DWIDTH-1:0] read_data1,
    output wire [DWIDTH-1:0] read_data2

 );

  parameter address_size = 2;// 4 address locations

  reg [DWIDTH-1:0] mem1 [2**address_size-1:0];
  reg [DWIDTH-1:0] mem2 [2**address_size-1:0];
  reg [address_size-1:0] wr_ptr, rd_ptr;
  reg [address_size-1:0] wr_ptr_next, rd_ptr_next;
  reg [address_size-1:0] wr_ptr_succ, rd_ptr_succ;

  reg full_reg;
  reg empty_reg;
  reg full_next;
  reg empty_next;

  wire w_en;

  always@(posedge clk)
    if(w_en)
    begin
      mem1[wr_ptr] <= write_data1;
      mem2[wr_ptr] <= write_data2;
    end

  //
  assign read_data1 = mem1[rd_ptr];
  assign read_data2 = mem2[rd_ptr];

  assign w_en = wr & ~full_reg;
  assign full = full_reg;
  assign empty = empty_reg;

  //State Machine
  always @ (posedge clk, posedge rst)
  begin
    if(rst)
    begin
      full_reg <= 1'b0;
      empty_reg <= 1'b1;
      wr_ptr <= 1'b0;
      rd_ptr <= 1'b0;
    end
    else
    begin
      full_reg <= full_next;
      empty_reg <= empty_next;
      wr_ptr <= wr_ptr_next;
      rd_ptr <= rd_ptr_next;
    end
  end

  // Need to add logic for updating read and write pointer here
  always@(*)
  begin
    wr_ptr_succ = wr_ptr+1;
    rd_ptr_succ = rd_ptr+1;

    wr_ptr_next = wr_ptr;
    rd_ptr_next = rd_ptr;
    full_next = full_reg;
    empty_next = empty_reg;

    case({w_en,rd})
      2'b00:
      begin
      end
      2'b01:
        if(~empty_reg)
        begin
          rd_ptr_next = rd_ptr_succ;
          full_next = 1'b0;

          if (rd_ptr_succ == wr_ptr)
            empty_next = 1'b1;
        end
      2'b10:
        if(~full_reg)
        begin
          wr_ptr_next = wr_ptr_succ;
          empty_next = 1'b0;

          if (wr_ptr_succ == rd_ptr)
            full_next = 1'b1;
      end
      2'b11:
      begin
        wr_ptr_next = wr_ptr_succ;
        rd_ptr_next = rd_ptr_succ;
      end
    endcase
  end // always @ (*)
endmodule

///////////////////////////////////////////////////////////////////////////////
// Module : ComplexMult
//
// Complex multiplier using DW02_mult module.
// Needs 4 instance of DW02 and 2 adders
//
// Operation : (A + iB)*(C + iD) = ((AC - BD) + i(BC + AD))
///////////////////////////////////////////////////////////////////////////////

module ComplexMult(input                    clk,
                   input                    reset,
                   input  reg signed [23:0] data_i,
                   input  reg signed [23:0] data_q,
                   input  reg signed [26:0] coef_i,
                   input  reg signed [26:0] coef_q,
                   output reg signed [53:0] mult_out_i,
                   output reg signed [53:0] mult_out_q);

  reg signed [53:0] prod_ac, prod_bd, prod_bc, prod_ad;

  DW02_mult_2_stage #(27,27) AC(.A({data_i[23], data_i[23], data_i[23], data_i}), .B(coef_i), .TC(1'b1), .CLK(clk), .PRODUCT(prod_ac));
  DW02_mult_2_stage #(27,27) BD(.A({data_q[23], data_q[23], data_q[23], data_q}), .B(coef_q), .TC(1'b1), .CLK(clk), .PRODUCT(prod_bd));
  DW02_mult_2_stage #(27,27) BC(.A({data_q[23], data_q[23], data_q[23], data_q}), .B(coef_i), .TC(1'b1), .CLK(clk), .PRODUCT(prod_bc));
  DW02_mult_2_stage #(27,27) AD(.A({data_i[23], data_i[23], data_i[23], data_i}), .B(coef_q), .TC(1'b1), .CLK(clk), .PRODUCT(prod_ad));

  assign mult_out_i = prod_ac - prod_bd; 
  assign mult_out_q = prod_bc + prod_ad;

endmodule

///////////////////////////////////////////////////////////////////////////////
// Module : pre_mult_adder
//
// Adder to add 2 Samples pre-complex-multiply.
///////////////////////////////////////////////////////////////////////////////
module pre_mult_adder(input                    clk,
                      input                    reset,
                      input  reg signed [23:0] a_i,
                      input  reg signed [23:0] a_q,
                      input  reg signed [23:0] b_i,
                      input  reg signed [23:0] b_q,
                      output reg signed [23:0] o_i,
                      output reg signed [23:0] o_q);

   always @ (posedge clk)
   begin
     if(reset)
     begin
       o_i <= 0;
       o_q <= 0;
     end
     else
     begin
       o_i <= a_i + b_i;
       o_q <= a_q + b_q;
     end
   end

endmodule
