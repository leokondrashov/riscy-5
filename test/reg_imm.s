.text
    addi x1, x0, 5
    mv x2, x1
    slti x1, x0, 5
    sltiu x1, x0, 5
    seqz x2, x1
    andi x1, x0, 5
    ori x1, x0, 5
    xori x1, x0, 5
    not x2, x1
    slli x2, x1, 5
    srli x2, x1, 5
    srai x2, x1, 5
    lui x3, 4097
    lui x3, 4096
    auipc x4, 4096
