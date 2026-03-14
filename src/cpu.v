`timescale 1ns / 1ps

`include "define.v"

module cpu(input clk,
           input rst,
           output [`DSIZE-1:0] out);

    assign out = dataIn1_d;
    wire [`ISIZE-1:0] instruction_f;

    fetch f(.clk(clk), .instruction(instruction_f));

    reg [`ISIZE-1:0] instruction_d; // pipeline buffer
    always @ (posedge clk) begin
        if (rst) begin
            instruction_d <= 0;
        end else begin
            instruction_d <= instruction_f;
        end
    end

    wire [`DSIZE-1:0] dataIn1_d;
    wire [`DSIZE-1:0] dataIn2_d;
    wire [4:0] rd_d;
    wire we_d;
    wire [2:0] ALUop_d;
    wire [0:0] extra_d;

    decode d(.clk(clk), .rst(rst), .instruction(instruction_d), .wb_data(dataOut_e), .wb_rd(rd_e), .wb_we(we_e),
    .data1(dataIn1_d), .data2(dataIn2_d), .rd(rd_d), .we(we_d), .ALUop(ALUop_d), .extra(extra_d));

    reg [`DSIZE-1:0] dataIn1_e; // pipeline buffer
    reg [`DSIZE-1:0] dataIn2_e; // pipeline buffer
    reg [4:0] rd_e;
    reg we_e;
    reg [2:0] ALUop_e;
    reg [0:0] extra_e;
    always @ (posedge clk) begin
        if (rst) begin
            dataIn1_e <= 0;
            dataIn2_e <= 0;
            rd_e <= 0;
            we_e <= 0;
            ALUop_e <= 0;
            extra_e <= 0;
        end else begin
            dataIn1_e <= dataIn1_d;
            dataIn2_e <= dataIn2_d;
            rd_e <= rd_d;
            we_e <= we_d;
            ALUop_e <= ALUop_d;
            extra_e <= extra_d;
        end
    end

    wire [`DSIZE-1:0] dataOut_e;

    execution e(.dataIn1(dataIn1_e), .dataIn2(dataIn2_e), .op(ALUop_e), .extra(extra_e), .dataOut(dataOut_e));

endmodule
