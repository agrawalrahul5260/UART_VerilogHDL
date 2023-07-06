`timescale 1ns / 1ps

module Tx
   #(parameter DATA_BIT = 8,
     parameter PARITY_ENABLED = 1,
     parameter STOP_BIT = 1)
    (
    input clk,
    input [DATA_BIT - 1:0] data,
    input reset,
    input transmit,
    input sample_tick,
    output reg TxD
    );
    
    localparam IDLE = 0;
    localparam TRANSFER = 1;
    
    reg [3:0] bit_counter;
    reg [3:0] sample_counter;
    reg [(DATA_BIT + PARITY_ENABLED + STOP_BIT):0] right_shift_reg;  
    reg present_state,next_state;
    reg parity_bit;
    reg shift; 
    reg load;
    reg bitcounter_rst;
    
       
   always @(posedge sample_tick) begin
       if(reset) begin
           present_state <= 0; //idle state(no tranext_statemission)
           bit_counter <= 0;
           sample_counter <= 0;          
       end
       
       else begin
           sample_counter <= sample_counter + 1;
           if(sample_counter == 15) begin
               sample_counter <= 0;
               present_state <= next_state;
               if(load) 
                   right_shift_reg <= (PARITY_ENABLED == 1) ? {1'b1,parity_bit,data, 1'b0}: {1'b1,data,1'b0};        /////
               if(bitcounter_rst) 
                   bit_counter <= 0;
               if(shift) begin
                   right_shift_reg <= (right_shift_reg>>1);
                   bit_counter <= bit_counter + 1;
               end                  
           end 
       end
   end
   
   //FSM
   always@(posedge clk) begin
       load <= 0;
       shift <= 0;
       bitcounter_rst <= 0;
       TxD <= 1;
       
       case(present_state)
               IDLE: begin
                     if(transmit) begin
                          next_state <= 1;
                          load <= 1;
                          shift <= 0;
                          bitcounter_rst <= 0;
                     end
                     else begin
                          next_state <= 0;
                          TxD <= 1;
                     end 
                     end  
           TRANSFER: begin
                     if(bit_counter == DATA_BIT + PARITY_ENABLED + STOP_BIT) begin    ////
                          next_state <= 0;
                          bitcounter_rst <= 1;
                     end
                  
                     else begin
                          next_state <= 1;
                          TxD <= right_shift_reg[0];
                          shift <= 1;
                     end
                     end
           default : next_state <= 0;
       endcase
   end   
endmodule
