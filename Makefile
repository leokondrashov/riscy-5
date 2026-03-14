VERILOG_OPTS=-I include

.PHONY: all sim clean

all: sim

sim: fetch_sim decode_sim

cpu_sim: src/fetch.v src/decode.v

%_sim: src/%.v src/%_tb.v
	iverilog ${VERILOG_OPTS} $^ -o sim/$@
	./sim/$@
	gtkwave sim/$*.vcd 2>/dev/null

clean:
	rm -f sim/* a.out dump.vcd
	rm -f test/*.o test/*.bin test/*.hex

test/%.hex: test/%.s
	riscv64-linux-gnu-as -march=rv32ima test/$*.s -o test/$*.o
	riscv64-linux-gnu-objcopy -O binary test/$*.o test/$*.bin
	hexdump test/$*.bin -e '1/1 "%02x" "\n"' > $@

addi_test: VERILOG_OPTS += -D IMEM_INIT_FILE_OVERRIDE='"test/addi.hex"'
addi_test: test/addi.hex cpu_sim

