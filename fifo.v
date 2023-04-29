`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2023 12:46:41 AM
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



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
    always@(posedge clk, posedge rst)
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
   always@*
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
              
                    
   end
   
endmodule
