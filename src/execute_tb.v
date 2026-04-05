`timescale 1ns / 1ps

`include "define.v"

module execute_tb;
    reg [2:0] op;
    reg [0:0] extra;
    reg [`DSIZE-1:0] di1, di2;
    wire [`DSIZE-1:0] do;

    execute uut (.op(op), .extra(extra), .dataIn1(di1), .dataIn2(di2), .dataOut(do));

    initial begin
        $dumpfile("sim/execute.vcd");
        $dumpvars;
        op = 0; extra = 0; di1 = 0; di2 = 0;
        #10 op = 0; di1 = 1; di2 = 1;
        #10 extra = 1; di1 = 1; di2 = 2;
        #10 op = 1; extra = 0;
        #10 op = 2; di1 = -1; di2 = 1;
        #10 di1 = 1; di2 = -1; // checking for other way
        #10 op = 3; di1 = -1; di2 = 1;
        #10 di1 = 1; di2 = -1; // checking for other way
        #10 op = 4; di1 = 1; di2 = 1;
        #10 op = 5; di1 = -4;
        #10 extra = 1;
        #10 op = 6; di1 = 1; di2 = 2;
        #10 op = 7;

        #20 $finish;
    end

endmodule
