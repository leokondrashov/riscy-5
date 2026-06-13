`timescale 1ns / 1ps

`include "define.v"

module data_forward_tb;
    reg ready;
    reg [4:0] dst_m, dst_w, dst_x, src1_e, src2_e, srcMem_e;
    reg [`DSIZE-1:0] di1, di2, memData, wb_m, wb_w, wb_x;
    wire [`DSIZE-1:0] di1_df, di2_df, memData_df;
    wire stall;

    data_forward uut (.readiness(ready), .dst_m(dst_m), .dst_w(dst_w), .dst_x(dst_x),
        .src1_e(src1_e), .src2_e(src2_e), .srcMem_e(srcMem_e),
        .dataIn1(di1), .dataIn2(di2), .memData(memData),
        .wb_data_m(wb_m), .wb_data_w(wb_w), .wb_data_x(wb_x),
        .dataIn1_df(di1_df), .dataIn2_df(di2_df), .memData_df(memData_df),
        .exec_stall(stall));

    initial begin
        $dumpfile("sim/data_forward.vcd");
        $dumpvars;
        ready = 1; dst_m = 0; dst_w = 0; dst_x = 0;
        src1_e = 0; src2_e = 0; srcMem_e = 0;
        di1 = 'hdead0001; di2 = 'hdead0002; memData = 'hdead0003;
        wb_m = 'hbeef0001; wb_w = 'hbeef0002; wb_x = 'hbeef0003;
        #10 dst_m = 1; dst_w = 2; dst_x = 3;
        #10 src1_e = 1;
        #10 src2_e = 1;
        #10 srcMem_e = 1;
        #10 ready = 0;

        #10 src1_e = 2;
        #10 src2_e = 2;
        #10 srcMem_e = 2;

        #10 src1_e = 3;
        #10 src2_e = 3;
        #10 srcMem_e = 3; ready = 1;

        #10 src1_e = 4;
        #10 src2_e = 4;
        #10 srcMem_e = 4;

        #10 src1_e = 1; src2_e = 2; srcMem_e = 3;

        // checks the priorities (need the earliest stage)
        #10 dst_m = 2;
        #10 dst_w = 3;
        #10 dst_x = 2;

        #20 $finish;
    end

endmodule
