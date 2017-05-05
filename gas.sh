#!/bin/bash
 #
 # Copyright © 2016, Monish Kapadia "assasin.monish" <monishk10@yahoo.com>
 #
 # Custom Build script for ease.
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #
 # Modified by @farchanrifai for Skymo Kernel

###########################################################################
# Bash Color
blink_red='\033[05;31m'
red=$(tput setaf 1) 		  # red
green=$(tput setaf 2)             # green
cyan=$(tput setaf 6) 		  # cyan
txtbld=$(tput bold)               # Bold
bldred=${txtbld}$(tput setaf 1)   # red
bldgrn=${txtbld}$(tput setaf 2)   # green
bldblu=${txtbld}$(tput setaf 4)   # blue
bldcya=${txtbld}$(tput setaf 6)   # cyan
restore=$(tput sgr0)              # Reset
clear

###########################################################################
# Resources
THREAD="-j12"
KERNEL="zImage"
OPT="CONFIG_NO_ERROR_ON_MISMATCH=y"
DTBIMAGE="dt.img"
device="cancro"
COMPILER="/home/farchan/ubertc-5.3/bin"

###########################################################################
# Directory naming
echo -e "${bldblu}"
#echo "Select Skymo version"
#echo "1. CM DTTW & S2W"
#echo "2. CM NO DTTW & S2W"
#echo "2. MIUI DTTW & S2W"
#echo "2. MIUI NO DTTW & S2W"
while read -p "Select Skymo version
1. CM DTTW & S2W
2. CM NO DTTW & S2W
3. MIUI DTTW & S2W
3. MIUI NO DTTW & S2W
Your choice: " mchoice
echo -e "${bldred}"
do
case "$mchoice" in
	1|1 )
		SKYMO_F="+"
		DEFCONFIG="lineageos_cancro_defconfig"
		VER="+"
		DIR="dttw"
		echo
		echo "DTTW -- S2W"
		break
		;;
	2|2 )
		SKYMO_F=""
		DEFCONFIG="lineageos_cancro_defconfig"
		VER=""
		DIR="polos"
		echo
		echo "POLOS -- NO DTTW"
		break
		;;
	3|3 )
		SKYMO_F="+_miui"
		DEFCONFIG="lineageos_cancro_defconfig"
		VER=""
		DIR="miui"
		echo
		echo "MIUI -- DTTW"
		break
		;;
    3|3 )
		SKYMO_F="_miui"
		DEFCONFIG="lineageos_cancro_defconfig"
		VER=""
		DIR="miui"
		echo
		echo "MIUI -- NO DTTW"
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done
###########################################################################
# Kernel Details
NAME="Skymo"
VERSION=""
DEVICE="_cancro"
SKYMO="$NAME$VER$VERSION$DEVICE"
TGL=$(date +"%d-%m-%y")
###########################################################################
# Vars
export CROSS_COMPILE="$COMPILER/arm-eabi-"
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER="Farchan"
export KBUILD_BUILD_HOST="WTF!!"


###########################################################################
# Paths
#STRIP=/toolchain-path/arm-eabi-strip
STRIP=$COMPILER/bin/arm-eabi-strip
KERNEL_DIR=`pwd`
REPACK_DIR="$KERNEL_DIR/zip/$SKYMO_F/kernel_zip"
DTBTOOL_DIR="$KERNEL_DIR"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"

###########################################################################
# Functions

function make_dtb {
		$DTBTOOL_DIR/dtbToolCM -s 2048 -d "qcom,msm-id = <" -2 -o $REPACK_DIR/$DTBIMAGE -p /usr/bin/ arch/arm/boot/

}
function clean_all {
		make clean && make mrproper
}

function alamat {
		cd ~/android/Builds
		mkdir -p $DIR/$TGL
		cd $DIR	
		COUNT=`ls ~/android/Builds/$DIR/$TGL -l | wc -l`
		NUMBER=$(($COUNT +1))
		NUMB="#$NUMBER"
}


function count {
		cd ~android/Builds
		COUNT=`ls ~/android/Builds -l | wc -l`
		NUMBER=$(($COUNT +1))
		NUMB="#$NUMBER"
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD $OPT 2>&1 | tee build.log
}

function skymo {
		echo "Make dtb & zip"
		for i in `find -name *.ko`; do cp $i ~/android/AnyKernel2/modules/; done
		$STRIP --strip-unneeded ~/android/AnyKernel2/modules/*.ko
		$DTBTOOL_DIR/dtbToolCM -s 2048 -d "qcom,msm-id = <" -2 -o arch/arm/boot/dt.img -p /usr/bin/ arch/arm/boot/
		cp arch/arm/boot/zImage ~/android/AnyKernel2/
		cp arch/arm/boot/dt.img ~/android/AnyKernel2/
		cd ~/android/AnyKernel2/modules
		rm *.ko
		cd ~/android/AnyKernel2
		DATE=$(date +"%d%m%y")
		rm *.zip
		zip -r9 $SKYMO-$DATE-$NUMB.zip * -x README $SKYMO-$DATE-$NUMB.zip
		cp *.zip ~/android/Builds/$DIR/$TGL
}

###########################################################################
DATE_START=$(date +"%s")

###########################################################################
echo -e "${bldred}"; echo -e "${blink_red}"; echo "$AK_VER"; echo -e "${restore}";

echo -e "${bldgrn}"
echo "----------------"
echo "Making SKYMO Kernel:"
echo "----------------"
echo -e "${restore}"

echo -e "${bldgrn}"
while read -p "Do you want to clean stuff (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done
echo -e "${restore}"
echo
echo -e "${txtbld}"
while read -p "Do you want to build kernel (y/n)? " dchoice
echo -e "${restore}"
do
case "$dchoice" in
	y|Y)
		make_kernel
		alamat
		cd $KERNEL_DIR
		if [ -e "arch/arm/boot/zImage" ]; then
		skymo
		else
		echo -e "${bldred}"
		echo "Kernel Compilation failed, run gedit build.log!!"
		echo -e "${restore}"
		exit 1
		fi
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done
echo -e "${bldgrn}"
echo "$SKYMO-$DATE-$NUMB.zip"
echo -e "${bldred}"
echo "###############################################################################"
echo -e "${bldgrn}"
echo "-------------------------Skymo Kernel Compiled in:-----------------------------"
echo -e "${bldred}"
echo "###############################################################################"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo -e "${bldblu}"
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo -e "${restore}"
echo

