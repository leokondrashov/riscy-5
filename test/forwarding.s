.text
    # checking the rs1 for arithmetic
    # intended wb_data: 5 (to x1); 5, 5, 5, 5 (to x2-x5)
    addi x1, x0, 5
    add x2, x1, x0
    add x3, x1, x0
    add x4, x1, x0
    add x5, x1, x0

    nop
    nop
    nop
    nop

    # checking the rs2 for arithmetic
    # intended wb_data: 3 (to x1); 3, 3, 3, 3 (to x2-x5)
    addi x1, x0, 3
    add x2, x0, x1
    add x3, x0, x1
    add x4, x0, x1
    add x5, x0, x1

    nop
    nop
    nop
    nop

    # checking DF from branch to exec
    # intended wb_data: 0x4c (to x1); (garbage due to stall); 0x4c, 0x4c, 0x4c, 0x4c (to x2-x5)
    jal x1, l1
l1: add x2, x0, x1
    add x3, x0, x1
    add x4, x0, x1
    add x5, x0, x1

    nop
    nop
    nop
    nop

    # checking for branching
    # intended jump_d high on pc_d = 0x70
    addi x1, x0, 0
    beq x0, x1, out
    beq x0, x1, out
    beq x0, x1, out
    beq x0, x1, out

out:
    nop
    nop
    nop
    nop

    addi x2, x0, 42
    nop
    nop
    nop
    # checking the address generation for sw/lw
    # intended dataOut_m (which is addr in mem stage): 0x2a, 0x2a, 0x2a, 0x2a
    addi x1, x0, 42
    sw x2, 0(x1)
    sw x2, 0(x1)
    sw x2, 0(x1)
    sw x2, 0(x1)

    # checking the dataIn for stores
    # intended memData_m: 0x18, 0x18, 0x18, 0x18
    addi x3, x0, 24
    sw x3, 4(x1)
    sw x3, 4(x1)
    sw x3, 4(x1)
    sw x3, 4(x1)

    # checking load-use forwarding
    # intended wb_data: 0x18 (to x2); 0x1c, 0x1c, 0x1c, 0x1c (to x3-x6)
    lw x2, 4(x1)
    addi x3, x2, 4
    addi x4, x2, 4
    addi x5, x2, 4
    addi x6, x2, 4
