
BASE = ..

SRC_DIR ?= src src/arch $(BASE)/external/bmlib/src

#
SRC_S = $(foreach dir,$(SRC_DIR), $(wildcard $(dir)/*.S) )
SRC_C = $(foreach dir,$(SRC_DIR), $(wildcard $(dir)/*.c) )
SRC_O= $(SRC_C:%.o=%.c) (SRC_S:%.o=%.S)

LDFILE = src/memory.ld

CFLAGS += -std=c99 -Wpadded
CFLAGS += -mthumb -mcpu=cortex-m0 -march=armv6-m
CROSS_COMPILE=arm-none-eabi-

CFLAGS += -nostartfiles -nostdlib -ffreestanding -Os -fno-common
CFLAGS += $(foreach dir,$(SRC_DIR), -I $(dir) )
LFLAGS += -T $(LDFILE)


##
all: build/sw.elf build/sw.bin build/sw0.bin \
	build/sw.hex build/sw0.hex  build/sw.dis build/sw.func

build/sw.bin: build/sw.elf
	$(CROSS_COMPILE)objcopy -O binary $< $@

build/sw.hex: build/sw.bin
	hexdump -v -e '/4 "%08X\n"' build/sw.bin > build/sw.hex

build/sw0.bin: build/sw.bin
	cp $< $@
	truncate -s 4096 $@

build/sw0.hex: build/sw0.bin
	hexdump -v -e '/4 "%08X\n"' $< > $@

build/sw.func: build/sw.dis
	grep "F .text" $< | awk '{print $$5, $$1, $$6}' | sort -r | uniq > $@

build/sw.dis: build/sw.elf
	$(CROSS_COMPILE)objdump -z -M reg-names-raw -D -x -t -r $< > $@

build/sw.elf: $(SRC_C) $(SRC_S) $(LDFILE) Makefile  build
	$(CROSS_COMPILE)gcc $(CFLAGS) $(SRC_C) $(SRC_S) $(LFLAGS) -o build/sw.elf


#


build:
	mkdir build

clean:
	-rm -rf build


show: build/sw.dis
	less build/sw.dis
