`timescale 1ns / 1ps

`include "define.v"

module fetch_tb;
    reg clk;
    wire [`ISIZE-1:0] instruction;

    fetch uut (.clk(clk), .instruction(instruction));

    initial begin
        $dumpfile("sim/fetch.vcd");
	$dumpvars;
        clk = 0;
	#40 $finish;
    end

    always #5 clk = ~clk;

endmodule
