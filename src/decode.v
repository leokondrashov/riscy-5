`timescale 1ns / 1ps

`include "define.v"

module decode(input clk, 
              input rst,
              input [`ISIZE-1:0] instruction,
              input [`DSIZE-1:0] wb_data,
              input [4:0] wb_rd,
              input wb_we,
              output [`DSIZE-1:0] data1,
              output [`DSIZE-1:0] data2,
              output [4:0] rd,
              output we,
              output [2:0] ALUop,
              output [0:0] extra);
    parameter OP_IMM=7'h13;

    reg [`DSIZE-1:0] regFile[`RFILE_SIZE-1:0];

    // works for OP-IMM inst only
    wire [11:0] immed = instruction[31:20];
    wire [`DSIZE-1:0] signExtImmed = {{`DSIZE-12{immed[11]}}, immed};
    wire [4:0] rs1 = instruction[19:15];

    assign data1 = regFile[rs1];
    assign data2 = signExtImmed;
    assign rd = instruction[11:7];
    assign we = 1;
    assign ALUop = instruction[14:12];
    assign extra = instruction[30:30];

    initial begin
        for (integer i = 0; i < `RFILE_SIZE; i = i + 1) begin
            regFile[i] = `DSIZE'b0;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            for (integer i = 0; i < `RFILE_SIZE; i = i + 1) begin
                 regFile[i] <= `DSIZE'b0;
            end
        end else if (wb_we) begin // write back from futher steps of pipeline
            regFile[wb_rd] <= (wb_rd == 0) ? 0 : wb_data;
        end
    end

endmodule
