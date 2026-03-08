`timescale 1ns / 1ps

`include "define.v"

module decode_tb;
    reg clk, rst;
    reg [`ISIZE-1:0] instruction;
    wire [`DSIZE-1:0] regData;

    decode uut (.clk(clk), .rst(rst), .instruction(instruction), .regData(regData));

    initial begin
        $dumpfile("sim/decode.vcd");
        $dumpvars;
        clk = 0;
        rst = 1;
        instruction = 32'b0;
        #10 rst = 0; instruction = 32'h00f00080; // addi x1, x0, 0xf
        #10 instruction = 32'h00108100; // addi x2, x1, 0x1
        // just reading
        #10 instruction = 32'h00000000; // addi x0, x0, 0x0
        #10 instruction = 32'h00008000; // addi x0, x1, 0x0
        #10 instruction = 32'h00010000; // addi x0, x2, 0x0
        #10 instruction = 32'h00018000; // addi x0, x3, 0x0
        #20 $finish;
    end

    always #5 clk = ~clk;

endmodule
