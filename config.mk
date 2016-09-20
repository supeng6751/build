#
# General configure file of X project's build system.
#
# (C) Copyright 2016 wowotech
#
# wowo<wowo@wowotech.net>
#
# SPDX-License-Identifier:	GPL-2.0+
#

#BOARD_NAME=bubblegum
#BOARD_ARCH=arm64

BOARD_NAME=tiny210
BOARD_ARCH=arm


##
## Defining rootfs image type that want be generate.
##
#ROOTFS_IMAGE_TYPE=ramdisk
ROOTFS_IMAGE_TYPE=initramfs


##
## Defining kernel image type that want be generate.
##
KERNEL_IMAGE_TYPE=fit_uimage
#KERNEL_IMAGE_TYPE=legacy_uimage


##
## Setting the load addr and entry addr of uImage.
##
#UIMAGE_LOADADDR=0x00080000
#UIMAGE_ENTRYADDR=0x00080000
UIMAGE_LOADADDR=0x20008000
UIMAGE_ENTRYADDR=0x20008040


##
## Setting the name of dtb
##
#DTB_NAME=actions/s900-bubblegum.dtb
DTB_NAME=s5pv210-tiny210.dtb
