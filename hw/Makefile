
NAME=m0
BASE = ..

# common files
DIR += src
DIR += src/cpu

# simulation
S0DIR += src/sim0
S0SRC = $(foreach dir,$(DIR) $(S0DIR), $(wildcard $(dir)/*.v) )
S0TOP = top_tb
EXE0 = build/sim0.exe

# post synth simulation
S1SRC += src/sim1/top_sim1.v
S1SRC += build/$(NAME).v
S1SRC += $(BASE)/external/yosys/techlibs/ice40/cells_sim.v
S1TOP = top_sim1
EXE1 = build/sim1.exe

# synthesis
DDIR += src/synth
DSRC = $(foreach dir,$(DIR) $(DDIR), $(wildcard $(dir)/*.v) )

PCF ?= src/synth/hx8k.pcf
DTOP ?= top_syn

# tools
IVERILOG = iverilog -Wall -g2001 -Iinclude
SYNTH = yosys -Q -l build/$(NAME).synth.log -v 1
PNR=nextpnr-ice40

# firmware dependencies
ROM = $(BASE)/build/rom.hex


# misc
LINT = verilator -Wall --lint-only --bbox-sys --bbox-unsup -Wno-STMTDLY -Iinclude

#
all: build $(EXE0)

#
# simulation
#
$(EXE0): build $(ROM)

$(EXE0): $(S0SRC)
	$(IVERILOG)  -s $(S0TOP) $(S0SRC) -o $@

build/waveform0.vcd: $(EXE0)
	$(EXE0) -h

sim0: build/waveform0.vcd

wave0: build/waveform0.vcd
	gtkwave build/waveform0.vcd

#
# post-synth simulation
#
hw/build/$(NAME).v: build/$(NAME).json
$(EXE1): $(S1SRC)
	$(IVERILOG) -s $(S1TOP) $(S1SRC) -o $@

build/waveform1.vcd: $(EXE1)
	$(EXE1)

sim1: build/waveform1.vcd

wave1: sim1
	gtkwave build/waveform1.vcd

#
# synthesis
#
synth: build/$(NAME).json
par: build/$(NAME).asc
# image: build/$(NAME).bin

program: build/$(NAME).bin
	iceprog build/$(NAME).bin

time: build/$(NAME).asc
	icetime -tmd hx8k build/$(NAME).asc

build/$(NAME).json: Makefile $(ROM) build
build/$(NAME).json: $(DSRC)
	$(SYNTH)  -p 'read_verilog -Iinclude $(DSRC)' -p 'synth_ice40 -top $(DTOP) -retime -json build/$(NAME).json' -o build/$(NAME).v
	-grep  -i -A 40 "Printing statistics" build/$(NAME).synth.log

build/$(NAME).asc: build/$(NAME).json $(PCF)
	$(PNR) --hx8k --json build/$(NAME).json --pcf $(PCF) --asc build/$(NAME).asc


build/$(NAME).bin: build/$(NAME).asc
	icepack build/$(NAME).asc build/$(NAME).bin

# misc
lint:
	-$(LINT)$(foreach d,$(DIR) $(S0DIR), -I$(d)) --top-module $(S0TOP) $(S0TOP) | tee build/lint.log
	-$(LINT)$(foreach d,$(DIR) $(DDIR), -I$(d)) --top-module $(DTOP) $(DTOP) | tee build/lint.log
#	for f in $(SRC); do $(LINT) $$f; done

build/$(NAME).ps: $(DSRC) build
	$(SYNTH) -p "prep; show -stretch -prefix build/$(NAME) -format ps" $(DSRC)

show: build/$(NAME).ps
	xdg-open build/$(NAME).ps

#

build:
	mkdir build

clean:
	rm -rf build
