`timescale 1ns / 1ps

`include "define.v"
`include "ops.v"

module memory(input clk,
              input rst,
              input [`DMEM_ADDR_SIZE-1:0] addr,
              input we,
              input en,
              input [`DSIZE-1:0] dataIn,
              input [2:0] width,
              output reg [`DSIZE-1:0] data);

    integer i;
    reg [7:0] mem[(1<<`DMEM_ADDR_SIZE)-1:0];

    initial begin
        for (i = 0; i < 1<<`DMEM_ADDR_SIZE; i++) begin
            mem[i] = 0;
        end
        data = 0;
    end

    always @ (posedge clk) begin
        if (rst) begin 
            for (i = 0; i < 1<<`DMEM_ADDR_SIZE; i++) begin
                mem[i] = 0;
            end
        end else if (en) begin
            if (we) begin
                case (width)
                    `WORD: {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]} <= dataIn;
                    `HWORD: {mem[addr+1], mem[addr]} <= dataIn[15:0];
                    `BYTE: mem[addr] <= dataIn[7:0];
                endcase
            end else begin
                case (width)
                    `WORD: data <= {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]};
                    `HWORD: data <= {16'b0, mem[addr+1], mem[addr]};
                    `HWORDU: data <= {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};
                    `BYTE: data <= {24'b0, mem[addr]};
                    `BYTEU: data <= {{24{mem[addr][7]}}, mem[addr]};
                endcase
            end
        end
    end

endmodule
