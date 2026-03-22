`timescale 1ns / 1ps

`include "define.v"

module cpu_tb;
    reg clk, rst;
    wire [`DSIZE-1:0] out;

    cpu uut (.clk(clk), .rst(rst), .out(out));

    initial begin
        $dumpfile("sim/cpu.vcd");
        $dumpvars;
        clk = 0; rst = 1;
        #10 rst = 0;
        #1000 $finish;
    end

    always #5 clk = ~clk;

endmodule
