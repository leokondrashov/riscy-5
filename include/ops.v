// Instruction opcodes
`define OP_IMM 7'h13
`define LUI 7'h37
`define AUIPC 7'h17
`define OP 7'h33
`define JAL 7'h6f
`define JALR 7'h67
`define BRANCH 7'h63
`define LOAD 7'h03
`define STORE 7'h23

// ALU operations codes
`define ADD 0
`define SL 1
`define SLT 2
`define SLTU 3
`define XOR 4
`define SR 5
`define OR 6
`define AND 7

// BRANCH conditions
`define BEQ 0
`define BNE 1
`define BLT 4
`define BGE 5
`define BLTU 6
`define BGEU 7

// MEM widths
`define WORD 2
`define HWORD 1
`define HWORDU 5
`define BYTE 0
`define BYTEU 4
