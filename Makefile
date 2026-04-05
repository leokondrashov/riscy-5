VERILOG_OPTS=-I include

.PHONY: all sim tests clean %_sim %_test

all: sim

SIMS=fetch_sim decode_sim execute_sim memory_sim cpu_sim
sims: ${SIMS}

TESTS=addi_test reg_imm_test reg_reg_test jump_test branch_test
tests: ${TESTS}

SRCS=$(wildcard src/*.v)

cpu_sim: src/fetch.v src/decode.v src/execute.v src/memory.v

%_sim: src/%.v src/%_tb.v
	iverilog ${VERILOG_OPTS} $^ -o sim/$@
	./sim/$@
	gtkwave sim/$*.vcd 2>/dev/null

test/%.hex: test/%.s
	riscv64-linux-gnu-as -march=rv32ima test/$*.s -o test/$*.o
	riscv64-linux-gnu-objcopy -O binary test/$*.o test/$*.bin
	xxd -p -c 1 test/$*.bin > $@

%_test: VERILOG_OPTS += -D IMEM_INIT_FILE='"test/$*.hex"'
%_test: test/%.hex ${SRCS} src/cpu_tb.v
	iverilog ${VERILOG_OPTS} ${SRCS} -s cpu_tb -o sim/$@
	./sim/$@
	gtkwave sim/cpu.vcd 2>/dev/null

clean:
	rm -f sim/* a.out dump.vcd
	rm -f test/*.o test/*.bin test/*.hex

