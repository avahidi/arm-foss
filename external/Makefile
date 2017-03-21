
all:

setup:
	# 1. get the tools
	sudo apt install iverilog gtkwave gcc-arm-none-eabi \
		build-essential clang bison flex minicom \
		libreadline-dev gawk tcl-dev libffi-dev git mercurial \
		graphviz xdot pkg-config python python3 libftdi-dev

	# 2. get the submodules
	git submodule update --init

	# 3. build bmlib, just to be sure
	CROSS_COMPILE=arm-none-eabi- make -C bmlib

	# 4. build them & install them as we go
	make -C icestorm -j`nproc`
	sudo make -C icestorm install

	make -C arachne-pnr -j`nproc`
	sudo make -C arachne-pnr install

	make -C yosys -j`nproc`
	sudo make -C yosys install

	# 5. add usb rules
	echo 'ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE:="666"' > 53-lattice-ftdi.rules
	sudo mv 53-lattice-ftdi.rules /etc/udev/rules.d/

clean:
	-make -C icestorm clean
	-make -C arachne-pnr clean
	-make -C yosys clean
	-make -C bmlib clean
