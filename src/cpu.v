`timescale 1ns / 1ps

`include "define.v"

module cpu(input clk,
           input rst,
           output [`DSIZE-1:0] out);

    assign out = dataIn1_d;

    wire [`ISIZE-1:0] instruction_d; // instruction bypasses the buffer
    wire [`IMEM_ADDR_SIZE-1:0] pc_f;

    fetch f(.clk(clk), .rst(rst), .newPC(dataOut_e[`IMEM_ADDR_SIZE-1:0]), .jump(jump_e), .instruction(instruction_d), .pc(pc_f));

    reg [`IMEM_ADDR_SIZE-1:0] pc_d; // pipeline buffer
    always @ (posedge clk) begin
        if (rst) begin
            pc_d <= 0;
        end else begin
            pc_d <= pc_f;
        end
    end

    wire [`DSIZE-1:0] dataIn1_d;
    wire [`DSIZE-1:0] dataIn2_d;
    wire [4:0] rd_d;
    wire we_d;
    wire jump_d;
    wire [2:0] ALUop_d;
    wire [0:0] extra_d;

    decode d(.clk(clk), .rst(rst), .instruction(instruction_d), .wb_data(wb_data), .wb_rd(rd_e), .wb_we(we_e), .pc(pc_d),
    .data1(dataIn1_d), .data2(dataIn2_d), .rd(rd_d), .we(we_d), .jump(jump_d), .ALUop(ALUop_d), .extra(extra_d));

    reg [`DSIZE-1:0] dataIn1_e; // pipeline buffer
    reg [`DSIZE-1:0] dataIn2_e; // pipeline buffer
    reg [4:0] rd_e;
    reg we_e;
    reg jump_e;
    reg [2:0] ALUop_e;
    reg [0:0] extra_e;
    reg [`IMEM_ADDR_SIZE-1:0] pc_e;
    always @ (posedge clk) begin
        if (rst) begin
            dataIn1_e <= 0;
            dataIn2_e <= 0;
            rd_e <= 0;
            we_e <= 0;
            jump_e <= 0;
            ALUop_e <= 0;
            extra_e <= 0;
            pc_e <= 0;
        end else begin
            dataIn1_e <= dataIn1_d;
            dataIn2_e <= dataIn2_d;
            rd_e <= rd_d;
            we_e <= we_d;
            jump_e <= jump_d;
            ALUop_e <= ALUop_d;
            extra_e <= extra_d;
            pc_e <= pc_d;
        end
    end

    wire [`DSIZE-1:0] dataOut_e;

    execute e(.dataIn1(dataIn1_e), .dataIn2(dataIn2_e), .op(ALUop_e), .extra(extra_e), .dataOut(dataOut_e));
    wire [`IMEM_ADDR_SIZE-1:0] nextPc = pc_e + 4;
    wire [`DSIZE-1:0] wb_data = jump_e ? {{`DSIZE-`IMEM_ADDR_SIZE{1'b0}}, nextPc} : dataOut_e; // handle writeback to register

endmodule
