VERILOG_OPTS=-I include

.PHONY: all test clean

all: test

test: fetch_test decode_test

%_test: src/%.v src/%_tb.v
	iverilog $^ ${VERILOG_OPTS} -o sim/$@
	./sim/$@
	gtkwave sim/$*.vcd 2>/dev/null

clean:
	rm sim/* a.out dump.vcd
