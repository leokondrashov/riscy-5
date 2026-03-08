`timescale 1ns / 1ps

`include "define.v"

module decode(input clk, 
              input rst,
              input [`ISIZE-1:0] instruction,
              output [`DSIZE-1:0] regData);

    reg [`DSIZE-1:0] regFile[`RFILE_SIZE-1:0];

    // works for ADDI inst only
    wire [11:0] immed = instruction[31:20];
    wire [4:0] rd = instruction[11:7];
    wire [4:0] rs1 = instruction[19:15];

    wire [`DSIZE-1:0] signExtImmed = {{`DSIZE-12{immed[11]}}, immed};

    assign regData = regFile[rs1];

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
        end else begin // x0 is hard-wired to zero, add immed for others
            regFile[rd] <= (rd == 0) ? `DSIZE'b0 : regFile[rs1] + signExtImmed;
        end
    end

endmodule
