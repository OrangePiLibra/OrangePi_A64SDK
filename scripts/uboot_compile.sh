#!/bin/bash
set -e
#################################
##
## Compile U-boot
## This script will compile u-boot and merger with scripts.bin, bl31.bin and dtb.
#################################
# ROOT must be top direct.
if [ -z $ROOT ]; then
	ROOT=`cd .. && pwd`
fi
# PLATFORM.
if [ -z $PLATFORM ]; then
	PLATFORM="OrangePiA64_Win"
fi
# Uboot direct
UBOOT=$ROOT/u-boot
# Compile Toolchain
TOOLS=$ROOT/toolchain/gcc-linaro-aarch/gcc-linaro/bin/arm-linux-gnueabihf-

# Perpar souce code
if [ ! -d $UBOOT ]; then
	whiptail --title "OrangePi Build System" \
		--msgbox "u-boot doesn't exist, pls perpare u-boot source code." \
		10 50 0
	exit 0
fi

clear
echo "Compile U-boot......"
if [ ! -f $UBOOT/u-boot-sun50iw1p1.bin ]; then
	make -C $UBOOT ARCH=arm CROSS_COMPILE=$TOOLS sun50iw1p1_config
fi
make -C $UBOOT ARCH=arm CROSS_COMPILE=$TOOLS 
echo "Complete compile...."

#####################################################################
###
### Merge uboot with different binary
#####################################################################
BINARY_PATH=$ROOT/external
MERGE_TOOLS=$ROOT/toolchain/pack-tools
BUILD=$ROOT/output

echo "BINARY_PATH $BINARY_PATH"
echo "MERGE_TOOLS $MERGE_TOOLS"
echo "BUILD $BUILD"

# Check direct
if [ -d $BUILD ]; then
	echo "output has exist, you can start merge"
else
	mkdir -p $BUILD
	echo "output direct build finish."
fi

echo "Perpare binary to merge."
cp -avf $BINARY_PATH/bl31.bin $BUILD
cp -avf $BINARY_PATH/scp.bin $BUILD
cp -avf $BINARY_PATH/sys_config.fex $BUILD
cp -avf $UBOOT/u-boot-sun50iw1p1.bin $BUILD/u-boot.bin

# Build binary device tree
dtc -Odtb -o $BUILD/orangepi.dtb $ROOT/kernel/arch/arm64/boot/dts/${PLATFORM}.dts 

# Build sys_config.bin
unix2dos $BUILD/sys_config.fex
$MERGE_TOOLS/script $BUILD/sys_config.fex

# Change path to hold current envirnoment
cd $ROOT/output
# Merge u-boot.bin infile outfile mode [secmonitor | secos | scp]
$MERGE_TOOLS/merge_uboot  u-boot.bin  bl31.bin  u-boot-merged.bin secmonitor
$MERGE_TOOLS/merge_uboot  u-boot-merged.bin  scp.bin  u-boot-merged2.bin scp

# Merge uboot and dtb
$MERGE_TOOLS/update_uboot_fdt u-boot-merged2.bin orangepi.dtb u-boot-with-dtb.bin

# Merge uboot and sys_config.fex
#$MERGE_TOOLS/update_uboot u-boot-with-dtb.bin sys_config.bin


# Clear build space
rm -rf u-boot-merg*
rm -rf u-boot.bin
rm -rf sys_config.*
rm -rf bl31.bin
rm -rf orangepi.dtb
rm -rf scp.bin

# Change to scripts direct.
cd -
whiptail --title "OrangePi Build System" \
	--msgbox "Build uboot finish. The output path: $BUILD/u-boot-with-dtb.bin" 10 60 0
