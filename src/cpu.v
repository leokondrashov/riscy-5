`timescale 1ns / 1ps

`include "define.v"

module cpu(input clk,
           input rst,
           output [`DSIZE-1:0] out);

    assign out = regData_r;
    wire [`ISIZE-1:0] instruction;

    fetch f(.clk(clk), .instruction(instruction));

    reg [`ISIZE-1:0] instruction_r; // pipeline buffer
    always @ (posedge clk) begin
        if (rst) begin
            instruction_r <= `ISIZE'b0;
        end else begin
            instruction_r <= instruction;
        end
    end

    wire [`DSIZE-1:0] regData;

    decode d(.clk(clk), .rst(rst), .instruction(instruction_r), .regData(regData));

    reg [`DSIZE-1:0] regData_r; // pipeline buffer
    always @ (posedge clk) begin
        if (rst) begin
            regData_r <= `DSIZE'b0;
        end else begin
            regData_r <= regData;
        end
    end

endmodule
