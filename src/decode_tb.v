`timescale 1ns / 1ps

`include "define.v"

module decode_tb;
    reg clk, rst;
    reg [`ISIZE-1:0] instruction;
    reg [`DSIZE-1:0] wb_data;
    reg [4:0] wb_rd;
    reg wb_we;
    reg [`IMEM_ADDR_SIZE-1:0] pc;
    wire [`DSIZE-1:0] data1;
    wire [`DSIZE-1:0] data2;
    wire [4:0] rd;
    wire we;
    wire jump;
    wire [2:0] memWidth;
    wire memWe;
    wire memEn;
    wire [`DSIZE-1:0] memData;
    wire [2:0] ALUop;
    wire [0:0] extra;

    decode uut (.clk(clk), .rst(rst), .instruction(instruction), .wb_data(wb_data), .wb_rd(wb_rd), .wb_we(wb_we), .pc(pc),
        .data1(data1), .data2(data2), .rd(rd), .we(we), .jump(jump), .memWidth(memWidth), .memWe(memWe), .memEn(memEn), .memData(memData), .ALUop(ALUop), .extra(extra));

    initial begin
        $dumpfile("sim/decode.vcd");
        $dumpvars;
        clk = 0;
        rst = 1;
        instruction = 32'b0;
        wb_data = 0;
        wb_rd = 0;
        wb_we = 0;
        pc = 42;
        #10 rst = 0; instruction = 32'h00f00093; // addi x1, x0, 0xf
        #10 instruction = 32'h00108113; // addi x2, x1, 0x1
        #10 instruction = 32'h00500093;
        #10 instruction = 32'h00008113;
        #10 instruction = 32'h00502093;
        #10 instruction = 32'h00503093;
        #10 instruction = 32'h0010b113;
        #10 instruction = 32'h00507093;
        #10 instruction = 32'h00506093;
        #10 instruction = 32'h00504093;
        #10 instruction = 32'hfff0c113;
        #10 instruction = 32'h00509113;
        #10 instruction = 32'h0050d113;
        #10 instruction = 32'h4050d113;
        #10 instruction = 32'h010011b7;
        #10 instruction = 32'h00412083;
        #10 instruction = 32'h00112223;
        #10 instruction = 32'h010001b7;
        #10 instruction = 32'h01000217;
        #10 instruction = 32'h13; wb_data = 32'h0f; wb_rd = 2; wb_we = 1;
        #10 instruction = 32'h08013; wb_we = 0; wb_rd = 1;
        #10 instruction = 32'h10013;
        #20 $finish;
    end

    always #5 clk = ~clk;

endmodule
