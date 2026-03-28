.text
# include nops to resolve the hazards in design without data forwarding
main:
    addi x2, x0, 13
    nop
    nop
    nop
    jal x1, fib
    nop
    nop
    nop
    j end
    nop
    nop

# takes the arg in x2, x3 is output
fib:
    addi x4, x0, 1
    xor x3, x3, x3
    nop
    nop
    blt x2, x4, return # if input < 1; return 0
    nop
    nop

input1:
    addi x3, x0, 1
    nop
    nop
    beq x2, x4, return # if input == 1; return 1
    nop
    nop

compute:
    addi x4, x0, 1 # i = 1, since we already have first two values
    sb x3, 1(x0) # mem[1] = 1, seed value for the loop
    nop
    nop

loop:
    lb x5, -1(x4)
    nop
    nop
    nop
    add x3, x3, x5
    nop
    nop
    nop
    sb x3, 1(x4)

    addi x4, x4, 1 # i++
    nop
    nop
    nop
    bne x2, x4, loop # if i != count, continue counting
    nop
    nop
    nop

return:
    jalr x0, x1

end: # done
    nop
    nop
    nop
    lw x0, 0(x0) # read the first 16 bytes, visible in memDataOut signal
    lw x0, 4(x0)
    lw x0, 8(x0)
    lw x0, 12(x0)
    nop
    nop
    nop
    nop
