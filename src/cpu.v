`timescale 1ns / 1ps

`include "define.v"

module cpu(input clk,
           input rst,
           output [`DSIZE-1:0] out);

    assign out = dataIn1_d;

    wire [`ISIZE-1:0] instruction_d; // instruction bypasses the buffer
    wire [`IMEM_ADDR_SIZE-1:0] pc_f;

    fetch f(.clk(clk), .rst(rst), .newPC(dataOut_e[`IMEM_ADDR_SIZE-1:0]), .jump(jump_e),
        .clear(jump_d || jump_e), .stall(stall_e), .instruction(instruction_d), .pc(pc_f));

    reg [`IMEM_ADDR_SIZE-1:0] pc_d; // pipeline buffer
    always @ (posedge clk) begin
        if (rst) begin
            pc_d <= 0;
        end else begin
            pc_d <= jump_d || jump_e ? 0 : stall_e ? pc_d : pc_f; // stall logic for pc propagation
        end
    end

    wire [`DSIZE-1:0] dataIn1_d;
    wire [`DSIZE-1:0] dataIn2_d;
    wire [4:0] rd_d;
    wire [4:0] rs1_d;
    wire [4:0] rs2_d;
    wire we_d;
    wire jump_d;
    wire ready_d; // tracks whether instruction would be ready at e (1) or m (0) stage
    wire [2:0] memWidth_d;
    wire memWe_d;
    wire memEn_d;
    wire [`DSIZE-1:0] memData_d;
    wire [2:0] ALUop_d;
    wire [0:0] extra_d;

    decode d(.clk(clk), .rst(rst), .instruction(instruction_d),
        .wb_data(wb_data), .wb_rd(rd_w), .wb_we(we_w), .pc(pc_d),
        .data1(dataIn1_d), .data2(dataIn2_d), .rd(rd_d), .src1(rs1_d), .src2(rs2_d), .we(we_d),
        .jump(jump_d), .readiness(ready_d),
        .memWidth(memWidth_d), .memWe(memWe_d), .memEn(memEn_d), .memData(memData_d),
        .ALUop(ALUop_d), .extra(extra_d)
    );

    reg [`DSIZE-1:0] dataIn1_e; // pipeline buffer
    reg [`DSIZE-1:0] dataIn2_e; // pipeline buffer
    reg [4:0] rd_e;
    reg [4:0] rs1_e;
    reg [4:0] rs2_e;
    reg we_e;
    reg jump_e;
    reg ready_e;
    reg [2:0] memWidth_e;
    reg memWe_e;
    reg memEn_e;
    reg [`DSIZE-1:0] memData_e;
    reg [2:0] ALUop_e;
    reg [0:0] extra_e;
    reg [`IMEM_ADDR_SIZE-1:0] pc_e;
    always @ (posedge clk) begin
        if (rst) begin
            dataIn1_e <= 0;
            dataIn2_e <= 0;
            rd_e <= 0;
            rs1_e <= 0;
            rs2_e <= 0;
            we_e <= 0;
            jump_e <= 0;
            ready_e <= 1;
            memWidth_e <= 0;
            memWe_e <= 0;
            memEn_e <= 0;
            memData_e <= 0;
            ALUop_e <= 0;
            extra_e <= 0;
            pc_e <= 0;
        end else if (stall_e) begin
            dataIn1_e <= dataIn1_e;
            dataIn2_e <= dataIn2_e;
            rd_e <= rd_e;
            rs1_e <= rs1_e;
            rs2_e <= rs2_e;
            we_e <= we_e;
            jump_e <= jump_e;
            ready_e <= ready_e;
            memWidth_e <= memWidth_e;
            memWe_e <= memWe_e;
            memEn_e <= memEn_e;
            memData_e <= memData_e;
            ALUop_e <= ALUop_e;
            extra_e <= extra_e;
            pc_e <= pc_e;
        end else begin
            dataIn1_e <= dataIn1_d;
            dataIn2_e <= dataIn2_d;
            rd_e <= rd_d;
            rs1_e <= rs1_d;
            rs2_e <= rs2_d;
            we_e <= we_d;
            jump_e <= jump_d;
            ready_e <= ready_d;
            memWidth_e <= memWidth_d;
            memWe_e <= memWe_d;
            memEn_e <= memEn_d;
            memData_e <= memData_d;
            ALUop_e <= ALUop_d;
            extra_e <= extra_d;
            pc_e <= pc_d;
        end
    end


    // data forwarding for execute stage; x is the fantom stage after wb
    wire [`DSIZE-1:0] dataIn1;
    wire [`DSIZE-1:0] dataIn2;
    wire [`DSIZE-1:0] memData;
    data_forward df(.readiness(ready_m), .exec_stall(stall_e),
        .dst_m(we_m ? rd_m : 5'b0), .dst_w(we_w ? rd_w : 5'b0), .dst_x(we_x ? rd_x : 5'b0),
        .wb_data_m(dataOut_m), .wb_data_w(wb_data), .wb_data_x(wb_data_x),
        .src1_e(rs1_e), .src2_e(memWe_e ? 5'b0 : rs2_e), .srcMem_e(memWe_e ? rs2_e : 5'b0),
        .dataIn1(dataIn1_e), .dataIn2(dataIn2_e), .memData(memData_e),
        .dataIn1_df(dataIn1), .dataIn2_df(dataIn2), .memData_df(memData)
    );

    wire [`DSIZE-1:0] dataOut_e;
    execute e(.dataIn1(dataIn1), .dataIn2(dataIn2), .op(ALUop_e), .extra(extra_e), .dataOut(dataOut_e));

    reg [`DSIZE-1:0] dataOut_m;
    reg [4:0] rd_m;
    reg we_m;
    reg jump_m;
    reg [2:0] memWidth_m;
    reg memWe_m;
    reg memEn_m;
    reg [`DSIZE-1:0] memData_m;
    reg [`IMEM_ADDR_SIZE-1:0] pc_m;
    reg ready_m;
    always @ (posedge clk) begin
        if (rst || stall_e) begin
            dataOut_m <= 0;
            rd_m <= 0;
            we_m <= 0;
            jump_m <= 0;
            memWidth_m <= 0;
            memWe_m <= 0;
            memEn_m <= 0;
            memData_m <= 0;
            pc_m <= 0;
            ready_m <= 1;
        end else begin
            dataOut_m <= dataOut_e;
            rd_m <= rd_e;
            we_m <= we_e;
            jump_m <= jump_e;
            memWidth_m <= memWidth_e;
            memWe_m <= memWe_e;
            memEn_m <= memEn_e;
            memData_m <= memData;
            pc_m <= pc_e;
            ready_m <= ready_e;
        end
    end

    wire [`DSIZE-1:0] memDataOut_w; // bypasses the pipeline register because already buffered
    memory m(.clk(clk), .rst(rst), .addr(dataOut_m[`DMEM_ADDR_SIZE-1:0]), .we(memWe_m), .en(memEn_m), .dataIn(memData_m), .width(memWidth_m), .data(memDataOut_w));

    reg [`DSIZE-1:0] dataOut_w;
    reg [4:0] rd_w;
    reg we_w;
    reg jump_w;
    reg memWe_w;
    reg memEn_w;
    reg [`IMEM_ADDR_SIZE-1:0] pc_w;
    always @ (posedge clk) begin
        if (rst) begin
            dataOut_w <= 0;
            rd_w <= 0;
            we_w <= 0;
            jump_w <= 0;
            memWe_w <= 0;
            memEn_w <= 0;
            pc_w <= 0;
        end else begin
            dataOut_w <= dataOut_m;
            rd_w <= rd_m;
            we_w <= we_m;
            jump_w <= jump_m;
            memWe_w <= memWe_m;
            memEn_w <= memEn_m;
            pc_w <= pc_m;
        end
    end

    wire [`IMEM_ADDR_SIZE-1:0] nextPc = pc_w + 4;
    wire [`DSIZE-1:0] wb_data = jump_w ? {{`DSIZE-`IMEM_ADDR_SIZE{1'b0}}, nextPc} : (memEn_w & !memWe_w) ? memDataOut_w : dataOut_w; // handle writeback to register

    // registers for data forwarding from writeback
    reg [`DSIZE-1:0] wb_data_x;
    reg [4:0] rd_x;
    reg we_x;
    always @ (posedge clk) begin
        if (rst) begin
            wb_data_x <= 0;
            rd_x <= 0;
            we_x <= 0;
        end else begin
            wb_data_x <= wb_data;
            rd_x <= rd_w;
            we_x <= we_w;
        end
    end

endmodule
