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
              output [`DSIZE-1:0] regData1,
              output [`DSIZE-1:0] regData2,
              output [4:0] rd,
              output [4:0] src1, // sources for data1, data2, masked
              output [4:0] src2,
              output [4:0] rs1, // raw souces
              output [4:0] rs2,
              output we,
              output jump,
              output [2:0] memWidth,
              output memWe,
              output memEn,
              output [2:0] ALUop,
              output [0:0] extra,
              output readiness); // encodes whether the result is ready after exec (1) or mem (0) stage
    integer i;
    reg [`DSIZE-1:0] regFile[`RFILE_SIZE-1:0];

    wire [6:0] op = instruction[6:0];

    // helpers identifying instruction type
    wire rtype = op == `OP;
    wire itype = op == `OP_IMM || op == `JALR || op == `LOAD;
    wire stype = op == `STORE;
    wire btype = op == `BRANCH;
    wire utype = op == `LUI || op == `AUIPC;
    wire jtype = op == `JAL;

    wire [`DSIZE-1:0] immed = itype ? {{20{instruction[31]}}, instruction[31:20]} :
        utype ? {instruction[31:12], 12'b0} :
        jtype ? {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0} :
        btype ? {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0} :
        stype ? {{20{instruction[31]}}, instruction[31:25], instruction[11:7]} : 0;
    wire [2:0] funct3 = instruction[14:12];
    wire condition = funct3 == `BEQ ? regFile[rs1] == regFile[rs2] :
        funct3 == `BNE ? regFile[rs1] != regFile[rs2] :
        funct3 == `BLT ? $signed(regFile[rs1]) < $signed(regFile[rs2]) :
        funct3 == `BGE ? $signed(regFile[rs1]) >= $signed(regFile[rs2]) :
        funct3 == `BLTU ? regFile[rs1] < regFile[rs2] :
        funct3 == `BGEU ? regFile[rs1] >= regFile[rs2] : 0;

    assign rs1 = instruction[19:15];
    assign regData1 = regFile[rs1];
    assign rs2 = instruction[24:20];
    assign regData2 = regFile[rs2];
    assign data1 = (rtype || itype || stype) ? regFile[rs1] : (op == `LUI ? 0 : pc);
    assign src1 = (rtype || itype || stype) ? rs1 : 0;
    assign data2 = rtype ? regFile[rs2] : immed;
    assign src2 = rtype ? rs2 : 0;
    assign rd = instruction[11:7];
    assign we = !btype && !stype;
    assign jump = op == `JAL || op == `JALR || (op == `BRANCH && condition);
    assign ALUop = op == `OP || op == `OP_IMM ? funct3 : `ADD;
    assign extra = (op == `OP || (op == `OP_IMM && ALUop == `SR)) ? instruction[30:30] : 0;
    assign memEn = op == `LOAD || op == `STORE;
    assign memWe = op == `STORE;
    assign memWidth = funct3;
    assign readiness = !(op == `LOAD || op == `JAL || op == `JALR);

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
