#!/bin/sh
###############################################################################
# Part of Marvell Yukon/SysKonnect sk98lin Driver for Linux                   #
###############################################################################
# Installation script for Marvell Chip based Ethernet Gigabit Cards           #
# =========================================================================== #
#                                                                             #
#  Main - Global function                                                     #
#                                                                             #
# Description:                                                                #
#  This file includes all functions and parts of the script                   #
#                                                                             #
# Returns:                                                                    #
#       N/A                                                                   #
# =========================================================================== #
# Usage:                                                                      #
#     ./install.sh                                                            #
#                                                                             #
# =========================================================================== #
# COPYRIGHT NOTICE :                                                          #
#                                                                             #
# (C)Copyright 2003-2012 Marvell(R).                                          #
#                                                                             #
#  LICENSE:
#  (C)Copyright Marvell.
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  The information in this file is provided "AS IS" without warranty.
#  /LICENSE                                                                   #
#                                                                             #
#                                                                             #
# WARRANTY DISCLAIMER:                                                        #
#                                                                             #
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT WITHOUT #
# ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF MERCHANTABILITY OR       #
# FITNESS FOR A PARTICULAR PURPOSE.                                           #
#                                                                             #
#                                                                             #
###############################################################################

# Check the existence of functions
if [ -f ./functions ] ; then
	. ./functions
elif [ -f /common/functions ] ; then
	. /common/functions
else
	# Error. Functions not found
	echo "An error has occurred during the check proces which prevented  "; \
	echo "the installation from completing.                              "; \
	echo "The functions file is not available.";
	echo "";
	exit 0
fi


function unpack_driver ()
{
	# Create tmp dir and unpack the driver
	# Syntax: unpack_driver
	# Author: mlindner
	# Returns:
	#       N/A


	# Create tmp dir and unpack the driver
	cd $working_dir
	fname="Unpack the sources"
	echo -n $fname
	message_status 3 "working"

	# Archive file not found
	if [ ! -f $drv_name.tar.bz2 ]; then
		echo -en "\015"
		echo -n $fname
		message_status 0 "error"
	 	echo
		echo "Driver package $drv_name.tar.bz2 not found. "; \
		echo "Please download the package again."; \
		echo "+++ Unpack error!!!" >> $logfile 2>&1
		echo $inst_failed
		clean
		exit 1

	fi

	echo "+++ Unpack the sources" >> $logfile
	echo "+++ ====================================" >> $logfile
	cp $drv_name.tar.bz2 ${TMP_DIR}/

	cd ${TMP_DIR}
	bunzip2 $drv_name.tar.bz2 &> /dev/null
	echo "+++ tar xfv $drv_name.tar" >> $logfile
	tar xfv $drv_name.tar >> $logfile
	cd ..

	if [ -f ${TMP_DIR}/2.6/skge.c ]; then
		echo -en "\015"
		echo -n $fname
		message_status 1 "done"
	else
		echo -en "\015"
		echo -n $fname
		message_status 0 "error"
	 	echo
		echo "An error has occurred during the unpack proces which prevented "; \
		echo "the installation from completing.                              "; \
		echo "Take a look at the log file install.log for more informations.  "; \
		echo "+++ Unpack error!!!" >> $logfile 2>&1
		echo $inst_failed
		clean
		exit 1
	fi

	# Get the source
	split_maj_kernel_ver=`echo ${KERNEL_FAMILY} | cut -d '.' -f 1`
	copyfamily=${KERNEL_FAMILY}
	if [ $split_maj_kernel_ver -gt 2 ]; then
		copyfamily="2.6"
	fi

	# Generate all build dir...
	mkdir ${TMP_DIR}/all &> /dev/null
	cp -pr ${TMP_DIR}/common/* ${TMP_DIR}/all
	cp -pr ${TMP_DIR}/${copyfamily}/* ${TMP_DIR}/all
	if [ $AVB_SUPPORT == "1" ]; then
		cp -pr ${TMP_DIR}/all/avb/* ${TMP_DIR}/all
	fi
}


function help ()
{
	echo "Usage: install.sh [OPTIONS]"
	echo "   Install the ${drv_name} driver or generate a patch"
  	echo "   Example: install.sh"
	echo
	echo "Optional parameters:"
	echo "   -s              compile the driver wothout any user interaction"
	echo "   -c              cleanup all sk98lin temp directories"
	echo "   -p [KERNEL_DIR] [PATCH_FILE]         generate a patch"
	echo "   -m              generate a makefile"
	echo "   -h              display this help and exit"
	echo "   -v              print version information and exit"
	echo
	echo "Report bugs to <support@marvell.com>."
	exit
}

function create_makefile ()
{
	# Create makefile
	# Syntax: create_makefile
	#	1 == change makefile for compilation
	#	1 != don't change
	# Author: mlindner
	# Returns:
	#       N/A

	# we have to use the makefile and change the include dir
	rm -rf ${TMP_DIR}/all/Makefile
 	if [ $1 == "1" ]; then
		rm -rf ${TMP_DIR}/all/Makefile
		local A="`echo | tr '\012' '\001' `"
		local AFirst="Idrivers/net/sk98lin"
		local ALast="I${TMP_DIR}/all"
		sed -e "s$A$AFirst$A$ALast$A" \
			${TMP_DIR}/2.6/Makefile \
			>> ${TMP_DIR}/all/Makefile
	else
		cp ${TMP_DIR}/2.6/Makefile ${TMP_DIR}/all/Makefile
	fi

	# Insert additional informations
	if [ ${KERNEL_SUB_VERSION} ] && [ ${KERNEL_MINOR_VERSION} -eq 23 ] && [ ${KERNEL_SUB_VERSION} -gt 6 ];
		then
		addparam="${addparam} -DSK_DISABLE_PROC_UNLOAD"

		addparam="ADDPARAM +=  $addparam"
		local addparamfirst="# ADDPARAM +="
			sed -e "s$A$addparamfirst$A$addparam$A" \
			${TMP_DIR}/all/Makefile \
			>> ${TMP_DIR}/all/Makefile2
		mv ${TMP_DIR}/all/Makefile2 ${TMP_DIR}/all/Makefile
	fi

	# Change the makefile for the SDK
	if [ $SDK_SUPPORT == "1" ]; then
		# Enable SDK support in the makefile
		local A="`echo | tr '\012' '\001' `"
		local SDKFirst="# SDKPARAM += -DMV_INCLUDE_SDK_SUPPORT"
		local SDKLast="SDKPARAM += -DMV_INCLUDE_SDK_SUPPORT"
		sed -e "s$A$SDKFirst$A$SDKLast$A" \
			${TMP_DIR}/all/Makefile \
			>> ${TMP_DIR}/all/Makefile2
		mv ${TMP_DIR}/all/Makefile2 ${TMP_DIR}/all/Makefile
	fi

	# Change the makefile for the AVB
	if [ $AVB_SUPPORT == "1" ]; then
		# Enable AVB support in the makefile
		local A="`echo | tr '\012' '\001' `"
		local AVBFirst="# AVBPARAM += -DSK_AVB"
		local AVBLast="AVBPARAM += -DSK_AVB"
		sed -e "s$A$AVBFirst$A$AVBLast$A" \
			${TMP_DIR}/all/Makefile \
			>> ${TMP_DIR}/all/Makefile2
		mv ${TMP_DIR}/all/Makefile2 ${TMP_DIR}/all/Makefile
	fi

}

function make_driver ()
{
	# Configure, check and build the driver
	# Syntax: make_driver
	# Author: mlindner
	# Returns:
	#       N/A

	# Compile the driver
	echo >> $logfile 2>&1
	echo "+++ Compile the driver" >> $logfile 2>&1
	echo "+++ ====================================" >> $logfile 2>&1
	cd ${TMP_DIR}/all

	fname="Compile the kernel"
	echo -n $fname
	message_status 3 "working"

	export CONFIG_SK98LIN=m

	if [ ${KERNEL_BUILD_OUTPUT} ]; then
		make $MAKE_CPU_FLAG CC=cc KBUILD_OUTPUT=${KERNEL_BUILD_OUTPUT} KBUILD_VERBOSE=1 -C ${KERNEL_SOURCE} SUBDIRS=${TMP_DIR}/all >> $logfile 2>&1
	else
		make $MAKE_CPU_FLAG KBUILD_VERBOSE=1 -C ${KERNEL_SOURCE}  SUBDIRS=${TMP_DIR}/all modules >> $logfile 2>&1
	fi

	if [ -f $drv_name.ko ]; then
		cp $drv_name.ko ../
		echo -en "\015"
		echo -n $fname
		message_status 1 "done"
	else
		echo -en "\015"
		echo -n $fname
		message_status 0 "error"
 		echo
		echo "An error has occurred during the compile proces which prevented "; \
		echo "the installation from completing.                              "; \
		echo "Take a look at the log file install.log for more informations.  "; \
		echo "+++ Compiler error" >> $logfile 2>&1
		echo $inst_failed
		cleanup
#		clean
		exit 1
	fi
}

function install_firmware ()
{
	# Install the firmware if available
	# Syntax: install_firmware
	# Author: mlindner
	# Returns:
	#       N/A
	echo -n "Check firmware availability"

	if [ -f ${TMP_DIR}/firmware/txbasesu.bin ]; then
		message_status 1 "available"

		echo -n "Copying firmware"
		cp ${TMP_DIR}/firmware/txbasesu.bin /lib/firmware/

#		SDK_SUPPORT=1
	fi

	message_status 1 "done"
}


#################################################################
# Generate patch functions
#################################################################
function check_driver_sources ()
{
	# Get some infos from the driver sources dir
	# Syntax: check_driver_sources
	# Author: mlindner
	# Returns:
	#       N/A

	local verstring=`cat ${TMP_DIR}/common/h/skversion.h | grep "VER_STRING"`
	DRIVER_VERSION=`echo $verstring | cut -d '"' -f 2`
	verstring=`cat ${TMP_DIR}/common/h/skversion.h | grep "DRIVER_REL_DATE"`
	DRIVER_REL_DATE=`echo $verstring | cut -d '"' -f 2`
}


function check_headers_for_patch ()
{
	# Get some infos from the Makefile
	# Syntax: check_headers_for_patch
	# Author: mlindner
	# Returns:
	#       N/A

	local mainkernel
	local patchkernel
	local sublevelkernel

	# Check header files
	if [ -d $KERNEL_SOURCE ]; then
		export KERNEL_SOURCE=$KERNEL_SOURCE
	else
		echo
		echo "An error has occurred during the patch proces which prevented "; \
		echo "the installation from completing.                              "; \
		echo "Directory $KERNEL_SOURCE not found!.  "; \
		echo $inst_failed
		cleanup
		clean
		exit 1
	fi

	if [ -f $KERNEL_SOURCE/Makefile ]; then
		export KERNEL_SOURCE=$KERNEL_SOURCE
	else
		echo
		echo "An error has occurred during the patch proces which prevented "; \
		echo "the installation from completing.                              "; \
		echo "Makefile in the directory $KERNEL_SOURCE not found!.  "; \
		echo $inst_failed
		cleanup
		clean
		exit 1
	fi


	# Get main version
	local mainversion=`grep "^VERSION =" $KERNEL_SOURCE/Makefile`
	local vercount=`echo $mainversion | wc -c`
	if [ $vercount -lt 1 ]; then
		mainversion=`grep "^VERSION=" $KERNEL_SOURCE/Makefile`
	fi
	mainkernel=`echo $mainversion | cut -d '=' -f 2 | sed -e "s/ //g"`

	# Get patchlevel
	local patchlevel=`grep "^PATCHLEVEL =" $KERNEL_SOURCE/Makefile`
	vercount=`echo $patchlevel | wc -c`
	if [ $vercount -lt 1 ]; then
		patchlevel=`grep "^PATCHLEVEL=" $KERNEL_SOURCE/Makefile`
	fi
	patchkernel=`echo $patchlevel | cut -d '=' -f 2 | sed -e "s/ //g"`

	# Get sublevel
	local sublevel=`grep "^SUBLEVEL =" $KERNEL_SOURCE/Makefile`
	vercount=`echo $sublevel | wc -c`
	if [ $vercount -lt 1 ]; then
		sublevel=`grep "^SUBLEVEL=" $KERNEL_SOURCE/Makefile`
	fi
	sublevelkernel=`echo $sublevel | cut -d '=' -f 2 | sed -e "s/ //g"`

	# Main Version checks
	if [ $mainkernel != 2 ] && [ $mainkernel != 3 ]; then
		kernel_check_failed
	fi

	# Check for kernel version 2.x
	if [ $mainkernel == 2 ] && [ $patchkernel != 4 ] && [ $patchkernel != 6 ]; then
		kernel_check_failed
	fi

	if [ "$sublevelkernel" -lt  20 ] && [ $patchkernel == 4 ]; then
		kernel_check_failed
	fi

	# Kernel version > 3.1 not supported in this install script
	if [ $mainkernel == 3 ] && [ $patchkernel -gt 1 ]; then
		echo
		echo "An error has occurred during the patch proces which prevented "; \
		echo "the patch generation from completing.                         "; \
		echo "Patch generation for Kernel version > 3.1 not supported yet   "; \
		echo "Please use the \"install\" or \"makefile\" install method     "; \
		echo $inst_failed
		cleanup
		clean
		exit 1
	fi

	KERNEL_VERSION=`echo "$mainkernel.$patchkernel.$sublevelkernel"`
	KERNEL_FAMILY=`echo "$mainkernel.$patchkernel"`
	KERNEL_MINOR_VERSION=$sublevelkernel
	KERNEL_MAJOR_VERSION=$patchkernel

}


function check_system_for_patch ()
{
	# Get some infos from host
	# Syntax: check_system_for_patch
	# Author: mlindner
	# Returns:
	#       N/A

	# Check kernel version

	export KERNEL_VERSION=`uname -r`
	split_kernel_ver=`echo ${KERNEL_VERSION} | cut -d '.' -f 1`

	KERNEL_FAMILY="$split_kernel_ver"
	split_kernel_ver=`echo ${KERNEL_VERSION} | cut -d '.' -f 2`
	KERNEL_FAMILY="$KERNEL_FAMILY.$split_kernel_ver"

	split_kernel_ver=`echo ${KERNEL_VERSION} | cut -d '.' -f 3`
	split_kernel_ver2=`echo $split_kernel_ver | cut -d '-' -f 1`
	KERNEL_MINOR_VERSION=`echo $split_kernel_ver2`
	KERNEL_MAJOR_VERSION=`echo ${KERNEL_VERSION} | cut -d '.' -f 2`

	# Check header files
	if [ -d /usr/src/linux/include/linux/ ]; then
		export KERNEL_SOURCE="/usr/src/linux";
	else
		if [ -d /usr/src/linux-${KERNEL_VERSION}/include/linux/ ]; then
			export KERNEL_SOURCE="/usr/src/linux-${KERNEL_VERSION}";
		else
			kernel_check_dir="linux-$KERNEL_FAMILY"
			if [ -d /usr/src/$kernel_check_dir/include/linux/ ]; then
				export KERNEL_SOURCE="/usr/src/$kernel_check_dir";
			fi
   		fi
	fi

}

function get_patch_infos ()
{
	# Interactive formular
	# Syntax: get_patch_infos
	# Author: mlindner
	# Returns:
	#       N/A

	if [ ! ${INSTALL_AUTO} ]; then
		PS3='Choose your favorite installation method: ' # Sets the prompt string.
		echo -n "Kernel source directory (${KERNEL_SOURCE}) : "
		read kernel_source_in
		if [ "$kernel_source_in" != "" ]; then
			KERNEL_SOURCE=$kernel_source_in
		fi
	fi

	# Check the headers
	check_headers_for_patch

	# Check driver version
	check_driver_sources

	if [ ! ${INSTALL_AUTO} ]; then
		drvvertmp=`echo $DRIVER_VERSION | sed -e "s/ //g"`
		drvvertmp=`echo $drvvertmp | cut -d '(' -f 1`
		PATCH_NAME="$working_dir/sk98lin_v"
		PATCH_NAME="$PATCH_NAME$drvvertmp"
		PATCH_NAME="${PATCH_NAME}_K${KERNEL_VERSION}.patch"

		echo -n "Patch name ($PATCH_NAME) : "
		read patch_name_in

		if [ "$patch_name_in" != "" ]; then
			case "$patch_name_in" in
			/*)
				PATCH_NAME="$patch_name_in"
			;;
			*)
				PATCH_NAME="$working_dir/$patch_name_in"
                       esac
		fi
	fi
}

function generate_patch_for_kconfig ()
{
	# Generate a patch for the config file
	# Syntax: generate_patch_for_kconfig
	#	package_root, kernel_root
	# Author: mlindner
	# Returns:
	#       N/A
	fname="Generate Kconfig patch"
	echo -n $fname
	message_status 3 "working"

	local packagedir="$1"
	local kerneldir=$2
	local startline
	local totalline
	local splitline
	local count=0
	local splt=0
	local A="`echo | tr '\012' '\001' `"

	# find the first line of the sk block
	startline=`grep "SK98LIN$" $kerneldir/drivers/net/Kconfig -n | grep -v "depends" | cut -d ':' -f 1`

	if [ ! ${startline} ]; then
		# Probably a new kernel... Check for SKGE
		startline=`grep "SKGE$" $kerneldir/drivers/net/Kconfig -n | grep -v "depends" | cut -d ':' -f 1`
		totalline=`cat $kerneldir/drivers/net/Kconfig | wc -l`
		((startline=$startline - 1))
		((splitline=$totalline - $startline))
		head -n $startline $kerneldir/drivers/net/Kconfig > ${TMP_DIR}/Kconfig
		cat $packagedir/misc/Kconfig >> ${TMP_DIR}/Kconfig
		tail -n $splitline $kerneldir/drivers/net/Kconfig >> ${TMP_DIR}/Kconfig
	else
		# Old kernel version. Replace the sk98lin driver
		totalline=`cat $kerneldir/drivers/net/Kconfig | wc -l`
		((startline=$startline - 1))
		((splitline=$totalline - $startline))
		((splitline=$splitline - 2))
		head -n $startline $kerneldir/drivers/net/Kconfig > ${TMP_DIR}/Kconfig
		cat $packagedir/misc/Kconfig >> ${TMP_DIR}/Kconfig
		tail -n $splitline $kerneldir/drivers/net/Kconfig > ${TMP_DIR}/Kconfigtemp

		# find the end of the block
		while read line; do
			((count=$count + 1))
			splt=`echo $line | grep "^config"  -c`
			if [ $splt -gt 0 ]; then break; fi
		done < ${TMP_DIR}/Kconfigtemp
		((count=$count - 2))
		((splitline=$splitline - $count))
		tail -n $splitline $kerneldir/drivers/net/Kconfig >> ${TMP_DIR}/Kconfig
	fi

	# Make diff
	diff -ruN $kerneldir/drivers/net/Kconfig ${TMP_DIR}/Kconfig \
		> ${TMP_DIR}/all_sources_patch
	replacement="linux-new/drivers/net"
	sed -e "s$A${TMP_DIR}$A$replacement$A" \
		${TMP_DIR}/all_sources_patch &> ${TMP_DIR}/all_sources_patch2
	replacement="linux"
	sed -e "s$A$kerneldir$A$replacement$A" \
		${TMP_DIR}/all_sources_patch2 &> ${TMP_DIR}/all_sources_patch


	# Complete the patch
	echo "diff -ruN linux/drivers/net/Kconfig \
linux-new/drivers/net/Kconfig" >> ${PATCH_NAME}
	cat ${TMP_DIR}/all_sources_patch >> ${PATCH_NAME}

	# Status
	echo -en "\015"
	echo -n $fname
	message_status 1 "done"
}

function generate_patch_for_makefile ()
{
	# Generate a patch for the config file
	# Syntax: generate_patch_for_makefile
	#	package_root, kernel_root
	# Author: mlindner
	# Returns:
	#       N/A
	fname="Generate Makefile patch"
	echo -n $fname
	message_status 3 "working"

	local packagedir="$1"
	local kerneldir=$2
	local startline
	local totalline
	local splitline
	local count=0
	local splt=0
	local A="`echo | tr '\012' '\001' `"

	# find the first line of the sk block
	startline=`grep "SK98LIN" $kerneldir/drivers/net/Makefile -n | cut -d ':' -f 1`

	if [ ! ${startline} ]; then
		# Probably a new kernel... Check for SKY2
		startline=`grep "SKY2" $kerneldir/drivers/net/Makefile -n | cut -d ':' -f 1`
		totalline=`cat $kerneldir/drivers/net/Makefile| wc -l`
		((splitline=$totalline - $startline))
		head -n $startline $kerneldir/drivers/net/Makefile > ${TMP_DIR}/Makefile

		echo "obj-\$(CONFIG_SK98LIN) += sk98lin/">> ${TMP_DIR}/Makefile
		tail -n $splitline $kerneldir/drivers/net/Makefile >> ${TMP_DIR}/Makefile

		# Make diff
		diff -ruN $kerneldir/drivers/net/Makefile ${TMP_DIR}/Makefile \
			> ${TMP_DIR}/all_sources_patch
		replacement="linux-new/drivers/net"
		sed -e "s$A${TMP_DIR}$A$replacement$A" \
			${TMP_DIR}/all_sources_patch &> ${TMP_DIR}/all_sources_patch2
		replacement="linux"
		sed -e "s$A$kerneldir$A$replacement$A" \
			${TMP_DIR}/all_sources_patch2 &> ${TMP_DIR}/all_sources_patch

		# Complete the patch
		echo "diff -ruN linux/drivers/net/Makefile \
linux-new/drivers/net/Makefile" >> ${PATCH_NAME}
		cat ${TMP_DIR}/all_sources_patch >> ${PATCH_NAME}
	fi

	# Status
	echo -en "\015"
	echo -n $fname
	message_status 1 "done"
}

function generate_patch_for_readme ()
{
	# Generate a patch for the readme file
	# Syntax: generate_patch_for_readme
	#	package_root, kernel_root
	# Author: mlindner
	# Returns:
	#       N/A

	fname="Generate readme patch"
	echo -n $fname
	message_status 3 "working"
	local packagedir="$1/all"
	local kerneldir=$2
	local replacement
	local A="`echo | tr '\012' '\001' `"

	# initial cleanup
	rm -rf ${TMP_DIR}/all_sources_patch

	# Make diff
	diff -ruN $kerneldir/Documentation/networking/sk98lin.txt $packagedir/sk98lin.txt \
		> ${TMP_DIR}/all_sources_patch
	replacement="linux-new/drivers/net/sk98lin"
	sed -e "s$A$packagedir$A$replacement$A" \
		${TMP_DIR}/all_sources_patch &> ${TMP_DIR}/all_sources_patch2
	replacement="linux/"
	nkerneldir="$kerneldir/"
	sed -e "s$A$nkerneldir$A$replacement$A" \
		${TMP_DIR}/all_sources_patch2 &> ${TMP_DIR}/all_sources_patch


	# Complete the patch

	if [ -f ${TMP_DIR}/all_sources_patch ] && \
		[ `cat ${TMP_DIR}/all_sources_patch | wc -c` -gt 0 ]; then
		echo "diff -ruN linux/Documentation/networking/sk98lin.txt \
linux-new/Documentation/networking/sk98lin.txt" >> ${PATCH_NAME}
		cat ${TMP_DIR}/all_sources_patch >> ${PATCH_NAME}
	fi

	# Status
	echo -en "\015"
	echo -n $fname
	message_status 1 "done"
}

function generate_patch_file ()
{
	# Generate a patch for a specific kernel version
	# Syntax: generate_patch_file
	#	package_root, kernel_root
	# Author: mlindner
	# Returns:
	#       N/A

	fname="Kernel version"
	echo -n $fname
	message_status 1 "${KERNEL_VERSION}"

	fname="Driver version"
	echo -n $fname
	message_status 1 "$DRIVER_VERSION"

	fname="Release date"
	echo -n $fname
	message_status 1 "$DRIVER_REL_DATE"

	# Check if some kernel functions are available
	check_kernel_functions

	fname="Generate driver patches"
	echo -n $fname
	message_status 3 "working"
	local packagedir="$1/all"
	local kerneldir=$2
	local replacement
	local line=`echo "-x '\*.\[o4\]' -x '.\*' -x '\*.ko' -x '\*.txt' -x '\*.htm\*' "`
	local A="`echo | tr '\012' '\001' `"

	diff -ruN -x "*.[o4]" -x ".*" -x "*.ko" -x "*.txt" -x "*.htm*" \
		$kerneldir/drivers/net/sk98lin $packagedir > ${TMP_DIR}/all_sources_patch
	replacement="linux-new/drivers/net/sk98lin"
	sed -e "s$A$packagedir$A$replacement$A" \
		${TMP_DIR}/all_sources_patch &> ${TMP_DIR}/all_sources_patch2
	replacement="linux"
	sed -e "s$A$kerneldir$A$replacement$A" \
		${TMP_DIR}/all_sources_patch2 &> ${TMP_DIR}/all_sources_patch
	replacement=`echo ""`
	sed -e "s$A$line$A$A" \
		${TMP_DIR}/all_sources_patch &> ${PATCH_NAME}

	# Status
	echo -en "\015"
	echo -n $fname
	message_status 1 "done"
}

function makefile_generation ()
{
	# Generate a makefile version
	# Syntax: makefile_generation
	# Author: mlindner
	# Returns:
	#       N/A

	# Create tmp dir and unpack the driver
	KERNEL_FAMILY=2.6
	TMP_DIR=src
	working_dir=`pwd`
	rm -rf src
	mkdir src &> /dev/null

	if [ $SDK_SUPPORT == "0" ]; then
		check_kernel_informations
	fi

	unpack_driver

	# Cleanup
	rm -rf src/sk98*
	rm -rf src/2.6
	rm -rf src/common
	rm -rf src/misc
	mv src/all/* src
	rm -rf src/all
	local A="`echo | tr '\012' '\001' `"

	# Change the makefile
	if [ $SDK_SUPPORT == "1" ]; then
		# Enable SDK support in the makefile
		local SDKFirst="# SDKPARAM += -DMV_INCLUDE_SDK_SUPPORT"
		local SDKLast="SDKPARAM += -DMV_INCLUDE_SDK_SUPPORT"
		sed -e "s$A$SDKFirst$A$SDKLast$A" \
			src/Makefile >> src/Makefile2
		mv src/Makefile2 src/Makefile
	fi

	if [ $AVB_SUPPORT == "1" ]; then
		# Enable AVB support in the makefile
		local AVBFirst="# AVBPARAM += -DSK_AVB"
		local AVBLast="AVBPARAM += -DSK_AVB"
		sed -e "s$A$AVBFirst$A$AVBLast$A" \
			src/Makefile >> src/Makefile2
		mv src/Makefile2 src/Makefile
	fi

	# Set the src directory
	local AFirst="Idrivers/net/sk98lin"
	local ALast="I${working_dir}/src"
	sed -e "s$A$AFirst$A$ALast$A" \
		src/Makefile >> src/Makefile2
	mv src/Makefile2 src/Makefile

	# Check for make command
	if [ ${KERNEL_BUILD_OUTPUT} ]; then
		make_command="make $MAKE_CPU_FLAG CC=cc KBUILD_OUTPUT=${KERNEL_BUILD_OUTPUT} -C ${KERNEL_SOURCE} SUBDIRS=${working_dir}/src"
	else
		make_command="make $MAKE_CPU_FLAG -C ${KERNEL_SOURCE} SUBDIRS=${working_dir}/src modules"
	fi

	clear

	# Print the makefile message
	echo
	echo
	echo "All done. Makefile version successfully generated."
	if [ $SDK_SUPPORT == "0" ]; then
		echo "To generate the driver, proceed as follows:"
		echo "  # export CONFIG_SK98LIN=m"
		echo "  # $make_command"
	fi
	echo
	echo "                                                     Have fun..."
	exit
}

function patch_generation ()
{
	# Generate a patch for a specific kernel version
	# Syntax: patch_generation
	# Author: mlindner
	# Returns:
	#       N/A

	# Check system
	check_system_for_patch

	# Generate safe tmp dir
	make_safe_tmp_dir

	# Create tmp dir and unpack the driver
	unpack_driver
	clear

	# Get user infos
	get_patch_infos

	# Copy files
	cp -pr ${TMP_DIR}/common/* ${TMP_DIR}/all
	cp -pr ${TMP_DIR}/${KERNEL_FAMILY}/* ${TMP_DIR}/all
	if [ $AVB_SUPPORT == "1" ]; then
		cp -vr ${TMP_DIR}/all/avb/* ${TMP_DIR}/all
	fi

	# Create makefile
	create_makefile 0
	clear

	# Generate a patch for a specific kernel version
	generate_patch_file ${TMP_DIR} $KERNEL_SOURCE

	# Generate a patch for the readme file
	generate_patch_for_readme ${TMP_DIR} $KERNEL_SOURCE

	# Generate a patch for the config file
	generate_patch_for_kconfig ${TMP_DIR} $KERNEL_SOURCE

	# Generate a patch for the Makefile
	generate_patch_for_makefile ${TMP_DIR} $KERNEL_SOURCE

	# Clear the tmp dirs
	clean

	if [ ! -f ${PATCH_NAME} ] || \
		[ `cat ${PATCH_NAME} | wc -c` == 0 ]; then
		rm -rf ${PATCH_NAME}
		echo
		echo "Patch not generated."
		echo "The sources already installed on the system in the directory "
		echo "     $KERNEL_SOURCE"
		echo "are equal to the sources from the install package."
		echo "This implies that it makes not sense to create the patch, "
		echo "because it'll be of size zero!"
		echo "Don't worry, this is not a failure. It just means, that you"
		echo "already use the latest driver version."
		echo
		echo "                                                     Have fun..."

		exit

	else
		echo
		echo "All done. Patch successfully generated."
		echo "To apply the patch to the system, proceed as follows:"
		echo "      # cd $KERNEL_SOURCE"
		echo "      # cat ${PATCH_NAME} | patch -p1"
		echo
		echo "                                                     Have fun..."
		exit
	fi
}




#################################################################
# Main functions
#################################################################
function start_sequence ()
{
	# Print copyright informations, mode selection and check
	# Syntax: start_sequence
	# Author: mlindner
	# Returns:
	#       N/A

	# Start. Choose a installation method and check method
	echo
	echo "Installation script for $drv_name driver."
	echo "Version $VERSION"
	echo "(C)Copyright 2003-2012 Marvell(R)."

	if [ $OPTION_VERSION ]; then
		exit;
	fi

	echo "===================================================="
	echo "Add to your trouble-report the logfile install.log"
	echo "which is located in the  DriverInstall directory."
	echo "===================================================="
	echo

	# Silent option. Return...
	[ "$OPTION_SILENT" ] && return
	[ "$INSTALL_AUTO" ] && patch_generation


	PS3='Choose your favorite installation method: ' # Sets the prompt string.

	echo

	select user_sel in "installation" "generate patch" "generate makefile" "exit"
	do
		break  # if no 'break' here, keeps looping forever.
	done

	if [ "$user_sel" == "exit" ]; then
		echo "Exit."
		exit
	fi

	if [ "$user_sel" != "installation" ] && [ "$user_sel" != "expert installation" ] && [ "$user_sel" != "generate patch" ] && [ "$user_sel" != "generate makefile" ]; then
		echo "Exit."
		exit
	fi

	clear


	if [ "$user_sel" == "generate makefile" ]; then
		export REMOVE_SKDEVICE=0
		INSTALL_MODE="MAKEFILE"
		makefile_generation
		exit
	fi

	if [ "$user_sel" == "installation" ]; then
		echo "Please read this carefully!"
		echo
		echo "This script will automatically compile and load the $drv_name"
		echo "driver on your host system. Before performing both compilation"
		echo "and loading, it is necessary to shutdown any device using the"
		echo "$drv_name kernel module and to unload the old $drv_name kernel "
		echo "module. This script will do this automatically per default."
		echo " "
		echo "Please plug a card into your machine. Without a card we aren't"
		echo "able to check the full driver functionality."
		echo
		echo -n "Do you want proceed? (y/N) "

		old_tty_settings=$(stty -g)		# Save old settings.
		stty -icanon
		Keypress=$(head -c1)
		stty "$old_tty_settings"			# Restore old terminal settings.
		echo "+++ Install mode: User" >> $logfile 2>&1
		echo "+++ Driver version: $VERSION" >> $logfile 2>&1

		if [ "$Keypress" == "Y" ]
		then
			clear
		else
			if [ "$Keypress" == "y" ]
			then
				clear
			else
				echo "Exit"
				clean
				exit 0
			fi
		fi
		export REMOVE_SKDEVICE=1

	else
		if [ "$user_sel" == "expert installation" ]; then
			INSTALL_MODE="INSTALL"
			echo "+++ Install mode: Expert" >> $logfile 2>&1
			clear
		else
			clear
			INSTALL_MODE="PATCH"
			patch_generation
		fi
	fi
}

function main_global ()
{
	# Main function
	# Syntax: main_global
	# Author: mlindner
	# Returns:
	#       N/A

	# Extract all given parameters
	extract_params $*

	# Run given functions
	if [ "${OPTION_SDK}" ]; then SDK_SUPPORT=1; fi
	if [ "${OPTION_AVB}" ]; then AVB_SUPPORT=1; fi
	if [ "${OPTION_HELP}" ]; then help; fi
	if [ "${OPTION_SILENT}" ]; then user_sel=`echo user`; fi
	if [ "${OPTION_LOG}" ]; then print_comp_resources; exit 0; fi
	if [ "${OPTION_CLEANUP}" ]; then clean; exit 0; fi
	if [ "${OPTION_PATCH}" ]; then
		INSTALL_MODE="PATCH"
		INSTALL_AUTO=1
		KERNEL_SOURCE=$2
		if [ `echo $3 | grep -c "/"` gt 0 ]; then
			PATCH_NAME=$3
		else
			PATCH_NAME=${working_dir}/$3
		fi
	fi

	if [ "${OPTION_MAKEFILE}" ]; then
		echo generate makefile
		INSTALL_MODE="MAKEFILE"
		makefile_generation
		exit 0
	fi

	# Delete log file
	rm -rf $logfile &> /dev/null

	# Print copyright informations, mode selection and check
	start_sequence

	# Check alternative driver availibility
	if [ ! "$OPTION_SILENT" ]; then
	check_alt_driver
	else
	# Don't check the sk98lin availability
	IGNORE_SKAVAIL_CHECK=1
	fi

	# Generate safe tmp dir
	make_safe_tmp_dir

	# Check user informations and tools availability
	check_user_and_tools

	# Check kernel and module informations
	check_kernel_informations

	# Check config files
	generate_config

	# Check if modpost is available
	check_modpost

	# Create tmp dir and unpack the driver
	unpack_driver

	# Install firmware if available
	install_firmware

	# Create makefile
	create_makefile 1

	# Check and generate a correct version.h file
	generate_sources_version

	# Check if some kernel functions are available
	check_kernel_functions


	# Configure, check and build the driver
	make_driver 1

	# Copy driver
	copy_driver

}


# Start
#####################################################################

drv_name=`echo sk98lin`
VERSION=`echo "10.93.3.3 (Aug-22-2012)"`
#drv_name=`echo sk98lin`
working_dir=`pwd`
logfile="$working_dir/install.log"
trap cleanup_trap INT TERM
KERNEL_TREE_MAKE=0;
ALT_OPTION_FLAG=0
ALT_OPTION=0
SDK_SUPPORT=0
AVB_SUPPORT=0


clear

# Run main function
main_global $*

# Exit
exit 0
