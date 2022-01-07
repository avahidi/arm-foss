
UART ?= /dev/ttyUSB1


all: sw hw

help:
	@echo "Valid targets are:"
	@echo "  For pre-synthesis   -  lint, sim0, wave0"
	@echo "  For post-synthesis  -  synth, sim1, wave1"
	@echo "  For FPGA flow       -  synth, par, time, program"
	@echo "  For UART to FPGA    -  console"
	@echo "  Administration      -  setup, clean, clean_all"

# software
.PHONY: sw
sw: build
	make -C sw
	cp sw/build/sw.bin build/rom.bin
	cp sw/build/sw.hex build/rom.hex

	cp sw/build/sw0.bin build/rom0.bin
	cp sw/build/sw0.hex build/rom0.hex


# hardware
.PHONY:	hw
hw: build
	make -C hw

# simulation
sim0: sw
	make -C hw sim0

wave0: sim0
	make -C hw wave0

# post-synth simulation
sim1: sw
	make -C hw sim1

wave1: sim1
	make -C hw wave1

# synhtesis, par, timing, bitstream programming
synth: sw
	make -C hw synth

par: sw
	make -C hw par

time: sw
	make -C hw time

program: sw
	make -C hw program

# misc
setup:
	git submodule update --init
	make -C external setup

lint:
	make -C hw lint

console:
	echo using UAR=$(UART), set UART to override...
	minicom -b 115200 -D $(UART) -C minicom.log

#

build:
	mkdir build


clean:
	make -C hw clean
	make -C sw clean

	rm -rf build

clean_all: clean
	make -C external clean
#	git submodule foreach make clean
