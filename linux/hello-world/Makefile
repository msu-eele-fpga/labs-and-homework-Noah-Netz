ifneq ($(KERNELRELEASE),)
# kbuild part of Makefile
obj-m := hello.o
else
# Normal Makefile
KDIR ?= linux-socfpga
PWD := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- M=$(PWD)

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
endif
