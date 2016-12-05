#!/bin/bash
set -e
#########################################################
##
##
## Update uboot and boot0
#########################################################
# ROOT must be top direct
if [ -z $ROOT ]; then
	ROOT=`cd .. && pwd`
fi
# Output path, must /dev/sdx
OUTPUT="$1"

UBOOT=$ROOT/output/u-boot-with-dtb.bin
UBOOT_SIZE=19096  # Kib

pv "$UBOOT" | dd conv=notrunc bs=1K seek=$UBOOT_SIZE of="$OUTPUT" &

sync
clear
whiptail --title "OrangePi Build System" --msgbox "Succeed to update Uboot and boot0" 10 40 0
