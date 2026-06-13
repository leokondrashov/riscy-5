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
                    input [4:0] src1_e, // sources are also masked by the need for the forward
                    input [4:0] src2_e, // e.g., dataIn2 and memData are exclusive since
                    input [4:0] srcMem_e, // during store dataIn2 is a constant
                    input [`DSIZE-1:0] dataIn1,
                    input [`DSIZE-1:0] dataIn2,
                    input [`DSIZE-1:0] memData,
                    input [`DSIZE-1:0] wb_data_m,
                    input [`DSIZE-1:0] wb_data_w,
                    input [`DSIZE-1:0] wb_data_x,
                    output reg [`DSIZE-1:0] dataIn1_df,
                    output reg [`DSIZE-1:0] dataIn2_df,
                    output reg [`DSIZE-1:0] memData_df,
                    output reg exec_stall);

    always @ (*) begin
        exec_stall <= (dst_m != 0) && !readiness && // simple cases of idempotent or ready instruction
            ((src1_e == dst_m) || (src2_e == dst_m) || (srcMem_e == dst_m));
        dataIn1_df <= src1_e == 0 ? dataIn1 :
            src1_e == dst_m ? wb_data_m :
            src1_e == dst_w ? wb_data_w :
            src1_e == dst_x ? wb_data_x :
            dataIn1;
        dataIn2_df <= src2_e == 0 ? dataIn2 :
            src2_e == dst_m ? wb_data_m :
            src2_e == dst_w ? wb_data_w :
            src2_e == dst_x ? wb_data_x :
            dataIn2;
        memData_df <= srcMem_e == 0 ? memData :
            srcMem_e == dst_m ? wb_data_m :
            srcMem_e == dst_w ? wb_data_w :
            srcMem_e == dst_x ? wb_data_x :
            memData;
    end


endmodule
