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

if [ -z "$OUTPUT" ]; then
	echo "Usage: $0 /dev/sdx"
	exit 1
fi

if [ "$(id -u)" -ne "0" ]; then
	echo "This option requires root."
	echo "Pls use command: sudo ./scripts.sh"
	exit 0
fi
UBOOT=$ROOT/output/u-boot-with-dtb.bin
UBOOT_SIZE=19096  # Kib

pv "$UBOOT" | dd conv=notrunc bs=1K seek=$UBOOT_SIZE of="$OUTPUT"

sync
echo -e "\e[1;31m ================================= \e[0m"
echo -e "\e[1;31m Succeed to Update Uboot and boot0 \e[0m"
echo -e "\e[1;31m ================================= \e[0m"
