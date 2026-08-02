`timescale 1ns / 1ps

`include "define.v"

module data_forward_tb;
    reg ready;
    reg [4:0] dst_m, dst_w, dst_x, src;
    reg [`DSIZE-1:0] di, wb_m, wb_w, wb_x;
    wire [`DSIZE-1:0] do;
    wire stall;

    data_forward uut (.readiness(ready), .dst_m(dst_m), .dst_w(dst_w), .dst_x(dst_x),
        .wb_data_m(wb_m), .wb_data_w(wb_w), .wb_data_x(wb_x),
        .src(src), .pipelineData(di), .dfResult(do),
        .stall(stall));

    initial begin
        $dumpfile("sim/data_forward.vcd");
        $dumpvars;
        ready = 1; dst_m = 0; dst_w = 0; dst_x = 0;
        src = 0; di = 'hdead0001;
        wb_m = 'hbeef0001; wb_w = 'hbeef0002; wb_x = 'hbeef0003;
        #10 dst_m = 1; dst_w = 2; dst_x = 3;
        #10 src = 1;
        #10 ready = 0;

        #10 src = 2;

        #10 src = 3;
        #10 ready = 1;

        #10 src = 4;

        #10 src = 2;

        // checks the priorities (need the earliest stage)
        #10 dst_m = 2;
        #10 dst_x = 2; dst_m = 0;
        #10 dst_m = 2; dst_w = 0;

        #20 $finish;
    end

endmodule
