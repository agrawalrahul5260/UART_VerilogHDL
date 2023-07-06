`timescale 1ns / 1ps

module top_tx(
    input clk,
    input [7:0]data,
    input reset,
    input transmit,
    output TxD
    );
    
    baudrate_generator f0(clk,reset,sample_tick);
    Tx f2(clk,data,reset,transmit,sample_tick,TxD);
endmodule
