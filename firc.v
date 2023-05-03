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
  reg signed [23:0] shift_reg_i[28:0];
  reg signed [23:0] shift_reg_q[28:0];

  wire signed [23:0] shift_reg_i_0;
  wire signed [23:0] shift_reg_q_0;

  reg [4:0] addr_0_loc_a, addr_1_loc_a, addr_2_loc_a,  addr_3_loc_a, addr_4_loc_a;
  reg [4:0] addr_0_loc_b, addr_1_loc_b, addr_2_loc_b,  addr_3_loc_b, addr_4_loc_b;

  reg [23:0] a2m_i_0, a2m_i_1, a2m_i_2, a2m_i_3, a2m_i_4;
  reg [23:0] a2m_q_0, a2m_q_1, a2m_q_2, a2m_q_3, a2m_q_4;

  reg fifo_rd_en;
  wire fifo_empty;

  // Separate connection for Adder_4_B as for 3rd multiply, it should be zero.
  reg signed [23:0] addr_4_b_i, addr_4_b_q;

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

  pre_mult_adder addr_0 (.clk(Clk), .reset(Reset), .a_i(shift_reg_i[addr_0_loc_a]), .a_q(shift_reg_q[addr_0_loc_a]), .b_i(shift_reg_i[addr_0_loc_b]), .b_q(shift_reg_q[addr_0_loc_b]), .o_i(a2m_i_0), .o_q(a2m_q_0));
  pre_mult_adder addr_1 (.clk(Clk), .reset(Reset), .a_i(shift_reg_i[addr_1_loc_a]), .a_q(shift_reg_q[addr_1_loc_a]), .b_i(shift_reg_i[addr_1_loc_b]), .b_q(shift_reg_q[addr_1_loc_b]), .o_i(a2m_i_1), .o_q(a2m_q_1));
  pre_mult_adder addr_2 (.clk(Clk), .reset(Reset), .a_i(shift_reg_i[addr_2_loc_a]), .a_q(shift_reg_q[addr_2_loc_a]), .b_i(shift_reg_i[addr_2_loc_b]), .b_q(shift_reg_q[addr_2_loc_b]), .o_i(a2m_i_2), .o_q(a2m_q_2));
  pre_mult_adder addr_3 (.clk(Clk), .reset(Reset), .a_i(shift_reg_i[addr_3_loc_a]), .a_q(shift_reg_q[addr_3_loc_a]), .b_i(shift_reg_i[addr_3_loc_b]), .b_q(shift_reg_q[addr_3_loc_b]), .o_i(a2m_i_3), .o_q(a2m_q_3));
  pre_mult_adder addr_4 (.clk(Clk), .reset(Reset), .a_i(shift_reg_i[addr_4_loc_a]), .a_q(shift_reg_q[addr_4_loc_a]), .b_i(addr_4_b_i),                .b_q(addr_4_b_q),                .o_i(a2m_i_4), .o_q(a2m_q_4));

  ComplexMult cm_0(.clk(Clk), .reset(Reset), .data_i(a2m_i_0), .data_q(a2m_q_0), .coef_i(), .coef_q(), .mult_out_i(), .mult_out_q());
  ComplexMult cm_1(.clk(Clk), .reset(Reset), .data_i(a2m_i_1), .data_q(a2m_q_1), .coef_i(), .coef_q(), .mult_out_i(), .mult_out_q());
  ComplexMult cm_2(.clk(Clk), .reset(Reset), .data_i(a2m_i_2), .data_q(a2m_q_2), .coef_i(), .coef_q(), .mult_out_i(), .mult_out_q());
  ComplexMult cm_3(.clk(Clk), .reset(Reset), .data_i(a2m_i_3), .data_q(a2m_q_3), .coef_i(), .coef_q(), .mult_out_i(), .mult_out_q());
  ComplexMult cm_4(.clk(Clk), .reset(Reset), .data_i(a2m_i_4), .data_q(a2m_q_4), .coef_i(), .coef_q(), .mult_out_i(), .mult_out_q());

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
    end
    else
    begin
      curr_state <= next_state;
    end
  end

  always @ (*)
  begin
    case(curr_state)
      ST_RESET :
      begin
        addr_0_loc_a = 0;
        addr_1_loc_a = 0;
        addr_2_loc_a = 0;
        addr_3_loc_a = 0;
        addr_4_loc_a = 0;

        addr_0_loc_b = 0;
        addr_1_loc_b = 0;
        addr_2_loc_b = 0;
        addr_3_loc_b = 0;
        addr_4_loc_b = 0;

        fifo_rd_en = 0;
        addr_4_b_i = 24'b0;
        addr_4_b_q = 24'b0;

        next_state = ST_MUL_0;
      end
      ST_MUL_0 :
      begin
        addr_0_loc_a = 0;
        addr_1_loc_a = 1;
        addr_2_loc_a = 2;
        addr_3_loc_a = 3;
        addr_4_loc_a = 4;

        addr_0_loc_b = 28;
        addr_1_loc_b = 27;
        addr_2_loc_b = 26;
        addr_3_loc_b = 25;
        addr_4_loc_b = 24;

        fifo_rd_en = 1;
        addr_4_b_i = shift_reg_i[addr_4_loc_b];
        addr_4_b_q = shift_reg_q[addr_4_loc_b];

        next_state = ST_MUL_1;
      end
      ST_MUL_1 :
      begin
        addr_0_loc_a = 5;
        addr_1_loc_a = 6;
        addr_2_loc_a = 7;
        addr_3_loc_a = 8;
        addr_4_loc_a = 9;

        addr_0_loc_b = 23;
        addr_1_loc_b = 22;
        addr_2_loc_b = 21;
        addr_3_loc_b = 20;
        addr_4_loc_b = 19;

        fifo_rd_en = 0;
        addr_4_b_i = shift_reg_i[addr_4_loc_b];
        addr_4_b_q = shift_reg_q[addr_4_loc_b];

        next_state = ST_MUL_2;
      end
      ST_MUL_2 :
      begin
        addr_0_loc_a = 10;
        addr_1_loc_a = 11;
        addr_2_loc_a = 12;
        addr_3_loc_a = 13;
        addr_4_loc_a = 14;

        addr_0_loc_b = 18;
        addr_1_loc_b = 17;
        addr_2_loc_b = 16;
        addr_3_loc_b = 15;
        addr_4_loc_b = 14;

        fifo_rd_en = 0;
        addr_4_b_i = 24'b0;
        addr_4_b_q = 24'b0;

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

  DW02_mult_2_stage #(27,27) AC(.A({data_i[23], data_i[23], data_i[23], data_i}), .B(coef_i), .TC(1'b1), .CLK(clk), .PRODUCT());
  DW02_mult_2_stage #(27,27) BD(.A({data_q[23], data_q[23], data_q[23], data_q}), .B(coef_q), .TC(1'b1), .CLK(clk), .PRODUCT());
  DW02_mult_2_stage #(27,27) BC(.A({data_q[23], data_q[23], data_q[23], data_q}), .B(coef_i), .TC(1'b1), .CLK(clk), .PRODUCT());
  DW02_mult_2_stage #(27,27) AD(.A({data_i[23], data_i[23], data_i[23], data_i}), .B(coef_q), .TC(1'b1), .CLK(clk), .PRODUCT());

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
