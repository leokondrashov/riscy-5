`timescale 1ns / 1ps

`include "define.v"

module fetch(input clk,
             output reg [`ISIZE-1:0] instruction);
    reg [`IMEM_ADDR_SIZE-1:0] PC;
    reg [7:0] imem[(1<<`IMEM_ADDR_SIZE)-1:0];

    initial begin
        if (`IMEM_INIT_FILE != "") begin
            $readmemh(`IMEM_INIT_FILE, imem);
        end
	PC = `IMEM_ADDR_SIZE'b0;
    end

    always @(posedge clk) begin
        PC <= PC + 4;
	instruction <= {imem[PC], imem[PC+1], imem[PC+2], imem[PC+3]};
    end

endmodule
