


DIR += src
DIR += src/ip/memory
DIR += src/ip/cpu
DIR += src/ip/sim


SRC = $(foreach dir,$(DIR), $(wildcard $(dir)/*.v) )
EXE = build/hw.exe

LINT = verilator -Wall --lint-only --bbox-sys --bbox-unsup -Wno-STMTDLY \
	$(foreach d,$(DIR), -I$(d))


all: $(EXE)

$(EXE): build $(SRC)
	iverilog -Wall -g2001 $(SRC) -o $(EXE)


lint:
	-$(LINT) src/top_tb.v 2>&1 | tee build/lint.log
#	for f in $(SRC); do $(LINT) $$f; done

#

build:
	mkdir build

clean:
	rm -rf build
