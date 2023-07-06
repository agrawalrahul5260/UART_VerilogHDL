`timescale 1ns / 1ps

module debouncer(
    input push_button,
    input clk,
    output debounced_op
    );

clkdvr f0(.clk(clk),.rst(0),.clkout(clkout));
dff f1(.clk(clkout),.d(push_button),.q(q0),.qbar(qbar0));
dff f2(.clk(clkout),.d(q0),.q(q1),.qbar(qbar1));

assign debounced_op = q0 & qbar1;
endmodule

module dff(
    input clk,
    input d,
    output reg q,
    output reg qbar
    );
    
always@(posedge clk) begin
    q <= d;
    qbar <= ~d;
end
endmodule

module clkdvr(
    input clk,
    input rst,
    output reg clkout
    );
    reg [25:0]count;
    always@ (posedge clk, posedge rst)
    begin
    if(rst == 1)
       begin
       count <= 0;
       clkout <= 1;
       end
    else
        begin
        if(count == 12_500_000)
            begin
            clkout <= ~clkout;
            count <= 0;
            end
        else
            count <= count + 1; 
        end
    end
    
endmodule
