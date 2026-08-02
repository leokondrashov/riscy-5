`timescale 1ns / 1ps

`include "define.v"

// idea is to streamline the data forwarding into a dependency resolution.
// for each instruction, we pass the stage for the result readiness (e.g.,
// mem for OP, wb for LOAD)
// when we forward, we check whether the data is ready (coming from a stage
// that supposed to have the correct data) and the dst-src checks
// generate stall signals if we don't have the data available

module data_forward(input readiness, // readiness of m stage (essentially, whether load is in M stage or not)
                    input [4:0] dst_m, // all destinations are masked by wb at respective stages, 0 if no wb
                    input [4:0] dst_w,
                    input [4:0] dst_x,
                    input [4:0] src, // sources are also masked by the need for the forward
                    input [`DSIZE-1:0] pipelineData,
                    input [`DSIZE-1:0] wb_data_m,
                    input [`DSIZE-1:0] wb_data_w,
                    input [`DSIZE-1:0] wb_data_x,
                    output reg [`DSIZE-1:0] dfResult,
                    output reg stall);

    always @ (*) begin
        stall <= (dst_m != 0) && !readiness && (src == dst_m); // need to wait for m stage
        dfResult <= src == 0 ? pipelineData :
            src == dst_m ? wb_data_m :
            src == dst_w ? wb_data_w :
            src == dst_x ? wb_data_x :
            pipelineData;
    end


endmodule
