#
# X project's genernal build system.
#
# (C) Copyright 2016 wowotech
#
# wowo<wowo@wowotech.net>
#
# SPDX-License-Identifier:	GPL-2.0+
#
include config.mk
include env_prepare.mk

BUILD_DIR=$(shell pwd)

TOOLS_DIR=$(BUILD_DIR)/../tools
LIBUSB_DIR=$(TOOLS_DIR)/common/libusb-1.0.20
DFU_DIR=$(TOOLS_DIR)/dfu
UBOOT_DIR=$(BUILD_DIR)/../u-boot
KERNEL_DIR=$(BUILD_DIR)/../linux
BUSYBOX_DIR=$(TOOLS_DIR)/common/busybox-1.24.2
ROOTFS_DIR=$(TOOLS_DIR)/common/rootfs

OUT_DIR=$(BUILD_DIR)/out
UBOOT_OUT_DIR=$(OUT_DIR)/u-boot
KERNEL_OUT_DIR=$(OUT_DIR)/linux
ROOTFS_OUT_DIR=$(OUT_DIR)/rootfs

ifeq ($(BOARD_ARCH), arm64)
KERNEL_DEFCONFIG=xprj_defconfig
else ifeq ($(BOARD_ARCH), arm)
KERNEL_DEFCONFIG=$(BOARD_NAME)_defconfig
ZIMAGE=zImage
endif

UIMAGE_ITS_FILE=$(BUILD_DIR)/fit_uImage_$(BOARD_NAME).its
UIMAGE_ITB_FILE=$(OUT_DIR)/xprj_uImage.itb

all: uboot kernel uImage

clean: dfu-clean uboot-clean kernel-clean rootfs-clean


libusb:
	cd $(LIBUSB_DIR) && ./configure && make && cd $(BUILD_DIR)

dfu:
	make -C $(DFU_DIR)

dfu-clean:
	make -C $(DFU_DIR) clean

#
# Be careful: the xxx_defconf file of your board will be overrided
#	after you running 'make uboot-config'.
#
uboot-config:
	mkdir -p $(UBOOT_OUT_DIR)
	cp -f $(UBOOT_DIR)/configs/$(BOARD_NAME)_defconfig $(UBOOT_OUT_DIR)/.config
	make -C $(UBOOT_DIR) KBUILD_OUTPUT=$(UBOOT_OUT_DIR) menuconfig
	cp -f $(UBOOT_OUT_DIR)/.config $(UBOOT_DIR)/configs/$(BOARD_NAME)_defconfig

uboot:
	mkdir -p $(UBOOT_OUT_DIR)
	make -C $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_COMPILE) KBUILD_OUTPUT=$(UBOOT_OUT_DIR) $(BOARD_NAME)_defconfig
	make -C $(UBOOT_DIR) CROSS_COMPILE=$(CROSS_COMPILE) KBUILD_OUTPUT=$(UBOOT_OUT_DIR)

uboot-clean:
	rm $(UBOOT_OUT_DIR) -rf

#
# Be careful: the xxx_defconf file of your board will be overrided
#	after you running 'make kernel-config'.
#
kernel-config:
	mkdir -p $(KERNEL_OUT_DIR)
	cp -f $(KERNEL_DIR)/arch/$(BOARD_ARCH)/configs/$(KERNEL_DEFCONFIG) $(KERNEL_OUT_DIR)/.config
	make -C $(KERNEL_DIR) KBUILD_OUTPUT=$(KERNEL_OUT_DIR) ARCH=$(BOARD_ARCH) menuconfig
	cp -f $(KERNEL_OUT_DIR)/.config $(KERNEL_DIR)/arch/$(BOARD_ARCH)/configs/$(KERNEL_DEFCONFIG)

kernel:
	mkdir -p $(KERNEL_OUT_DIR)
	make -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) KBUILD_OUTPUT=$(KERNEL_OUT_DIR) ARCH=$(BOARD_ARCH) $(KERNEL_DEFCONFIG)
	make -C $(KERNEL_DIR) CROSS_COMPILE=$(CROSS_COMPILE) KBUILD_OUTPUT=$(KERNEL_OUT_DIR) ARCH=$(BOARD_ARCH) Image dtbs $(ZIMAGE)

kernel-clean:
	rm $(KERNEL_OUT_DIR) -rf

uImage:
	mkdir -p $(OUT_DIR)
	$(UBOOT_OUT_DIR)/tools/mkimage -f $(UIMAGE_ITS_FILE) $(UIMAGE_ITB_FILE)

kernel-img:
	./mkkernelimg.sh $(KERNEL_IMAGE_TYPE) $(BOARD_NAME) $(BOARD_ARCH) $(CROSS_COMPILE) $(UIMAGE_LOADADDR) $(UIMAGE_ENTRYADDR)

#
# It will build busybox in tools dir and install.
# Notice : I have generate a .config for busybox and set the install dir to the dir of rootfs.
#          It will install those bin file to tools/common/rootfs automatically.
#          If it is not necessary, you don't need make menuconfig or make defconfig.
#
busybox:
	make -C $(BUSYBOX_DIR) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(BOARD_ARCH)
	make -C $(BUSYBOX_DIR) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(BOARD_ARCH) install

busybox-clean:
	make -C $(BUSYBOX_DIR) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(BOARD_ARCH) clean

rootfs:
	./mkrootfs.sh $(ROOTFS_IMAGE_TYPE) $(BOARD_NAME) $(BOARD_ARCH)

rootfs-clean:
	rm $(ROOTFS_OUT_DIR) -rf
