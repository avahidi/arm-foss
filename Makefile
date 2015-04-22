


all: build hw sw
	cp sw/build/sw.bin build/rom.bin
	cp hw/build/hw.exe build/hw.exe

run: all
	cd build && ./hw.exe

show: run
	cd build && gtkwave waveform.vcd

#

.PHONY:	hw
.PHONY: sw

hw:
	make -C hw

sw:
	make -C sw

lint:
	make -C hw lint

#
setup:
	sudo apt install iverilog gtkwave gcc-arm-none-eabi
	git submodule update --init
	CROSS_COMPILE=arm-none-eabi- git submodule foreach make


#

build:
	mkdir build


clean:
	make -C hw clean
	make -C sw clean
	rm -rf build

clean_all: clean
	git submodule foreach make clean
