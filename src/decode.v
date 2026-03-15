`timescale 1ns / 1ps

`include "define.v"
`include "ops.v"

module decode(input clk, 
              input rst,
              input [`ISIZE-1:0] instruction,
              input [`DSIZE-1:0] wb_data,
              input [4:0] wb_rd,
              input wb_we,
              input [`IMEM_ADDR_SIZE-1:0] pc,
              output [`DSIZE-1:0] data1,
              output [`DSIZE-1:0] data2,
              output [4:0] rd,
              output we,
              output [2:0] ALUop,
              output [0:0] extra);
    integer i;
    reg [`DSIZE-1:0] regFile[`RFILE_SIZE-1:0];

    // works for reg-imm inst only
    wire [`DSIZE-1:0] immed = op == `OP_IMM ? {{`DSIZE-12{instruction[31]}}, instruction[31:20]} : {instruction[31:12], 12'b0};
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [6:0] op = instruction[6:0];

    assign data1 = (op == `OP_IMM || op == `OP) ? regFile[rs1] : (op == `LUI ? 0 : pc);
    assign data2 = op == `OP ? regFile[rs2] : immed;
    assign rd = instruction[11:7];
    assign we = 1;
    assign ALUop = op == `OP_IMM ? instruction[14:12] : `ADD;
    assign extra = (op == `OP || (op == `OP_IMM && ALUop == `SR)) ? instruction[30:30] : 0;

    initial begin
        for (i = 0; i < `RFILE_SIZE; i = i + 1) begin
            regFile[i] = `DSIZE'b0;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            for (i = 0; i < `RFILE_SIZE; i = i + 1) begin
                 regFile[i] <= `DSIZE'b0;
            end
        end else if (wb_we) begin // write back from futher steps of pipeline
            regFile[wb_rd] <= (wb_rd == 0) ? 0 : wb_data;
        end
    end

endmodule
