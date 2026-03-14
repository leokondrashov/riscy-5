`timescale 1ns / 1ps

`include "define.v"

module fetch(input clk,
             input rst,
             output reg [`ISIZE-1:0] instruction,
             output reg [`IMEM_ADDR_SIZE-1:0] pc);
    reg [7:0] imem[(1<<`IMEM_ADDR_SIZE)-1:0];

    initial begin
        if (`IMEM_INIT_FILE != "") begin
            $readmemh(`IMEM_INIT_FILE, imem);
        end
        pc = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            pc <= 0;
            instruction <= 32'h13; // NOP
        end else begin
            pc <= pc + 4;
            instruction <= {imem[pc+3], imem[pc+2], imem[pc+1], imem[pc]};
        end
    end

endmodule
