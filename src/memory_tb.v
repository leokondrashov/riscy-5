`timescale 1ns / 1ps

`include "define.v"

module memory_tb;
    reg clk, rst, we, en;
    reg [`DMEM_ADDR_SIZE-1:0] addr;
    reg [`DSIZE-1:0] dataIn;
    reg [2:0] width;
    wire [`DSIZE-1:0] data;

    memory uut(.clk(clk), .rst(rst), .we(we), .en(en), .addr(addr), .dataIn(dataIn), .width(width), .data(data));

    initial begin
        $dumpfile("sim/memory.vcd");
        $dumpvars;
        clk = 0;
        rst = 1;
        width = `WORD;
        #10 rst = 0;
        
        #10 we = 1; en = 1; dataIn = 'h01020304; addr = 0;
        #10 en = 0; dataIn = 'h05060708; addr = 4;
        #10 we = 0; en = 1; dataIn = 'h090a0b0c; addr = 8;
        #10 we = 1; dataIn = 'hdeadbeef; addr = 12; width = `HWORD;
        #10 dataIn = 'hf00ddea1; addr = 16; width = `BYTE;

        #10 we = 0; dataIn = 0; addr = 0; width = `WORD;
        #10 addr = 4;
        #10 addr = 8;
        #10 addr = 12;
        #10 addr = 16;
        #10 addr = 12; width = `HWORD;
        #10 width = `HWORDU;
        #10 width = `BYTE;
        #10 width = `BYTEU;
        #20 $finish;
    end

    always #5 clk = ~clk;

endmodule
