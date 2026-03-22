`timescale 1ns / 1ps

`include "define.v"
`include "ops.v"

module execute (input [2:0] op,
                input [0:0] extra, // extra mod of op (logical shift -> arithmetic, add -> sub)
                input [`DSIZE-1:0] dataIn1,
                input [`DSIZE-1:0] dataIn2,
                output reg [`DSIZE-1:0] dataOut);

    always @ (*) begin
        case(op)
            `ADD: dataOut = extra[0] ? dataIn1 - dataIn2 : dataIn1 + dataIn2;
            `SLT: dataOut = $signed(dataIn1) < $signed(dataIn2) ? 1 : 0;
            `SLTU: dataOut = dataIn1 < dataIn2 ? 1 : 0; // comparison by default is unsigned
            `AND: dataOut = dataIn1 & dataIn2;
            `OR: dataOut = dataIn1 | dataIn2;
            `XOR: dataOut = dataIn1 ^ dataIn2;
            `SL: dataOut = dataIn1 << dataIn2[4:0];
            `SR: begin
                    if (extra[0] == 0)
                        dataOut = dataIn1 >> dataIn2[4:0];
                    else
                        dataOut = $signed(dataIn1) >>> $signed(dataIn2[4:0]);
                end
            default: dataOut = `DSIZE'b0;
        endcase
    end

endmodule
