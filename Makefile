VERILOG_OPTS=-I include

.PHONY: all test

all: test

test: fetch_test

fetch_test:
	iverilog src/fetch.v src/fetch_tb.v ${VERILOG_OPTS} -o sim/fetch_test
	./sim/fetch_test
	gtkwave sim/fetch.vcd 2>/dev/null
