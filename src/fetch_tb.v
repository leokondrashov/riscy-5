`timescale 1ns / 1ps

`include "define.v"

module fetch_tb;
    reg clk;
    reg rst;
    reg [`IMEM_ADDR_SIZE-1:0] newPC;
    reg jump;
    wire [`IMEM_ADDR_SIZE-1:0] pc;
    wire [`ISIZE-1:0] instruction;

    fetch uut (.clk(clk), .rst(rst), .newPC(newPC), .jump(jump), .instruction(instruction), .pc(pc));

    initial begin
        $dumpfile("sim/fetch.vcd");
        $dumpvars;
        clk = 0;
        rst = 1;
        jump = 0;
        newPC = 0;
        #10 rst = 0;
        #50 jump = 1; newPC = 4;
        #10 jump = 0;
        #100 $finish;
    end

    always #5 clk = ~clk;

endmodule
