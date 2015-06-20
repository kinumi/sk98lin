(C)Copyright 1999-2012 Marvell(R).
All rights reserved.
================================================================================

sk98lin.txt created 22-Aug-2012

Readme File for sk98lin v10.93.3.3
Marvell Yukon/SysKonnect SK-98xx Gigabit Ethernet Adapter driver for Linux
Installation Instructions for sk98lin Driver

This file contains
 1  Overview
 2  Required Files and Tools
 3  Prerequisites
 4  Preparing the Driver Installation Package
 5  Driver Installation
    5.1  Installation Mode
    5.2  Patch Generation Mode
    5.3  Generate Makefile Mode
 6  Patch Generation and Recompilation of the Kernel
    6.1  Downloading and Unpacking the Linux Kernel
    6.2  Generating the Driver Patch
    6.3  Applying the Driver Patch
    6.4  Configuring the Linux Kernel
    6.5  Compiling and Installing the Linux Kernel
 7  Generate Makefile Mode
 8  Manual Module Loading
 9  Unloading the Module
10  Driver Parameters
11  Ethtool Commands
12  Troubleshooting
================================================================================


1  Overview
===========

This document describes the installation of the sk98lin driver 
on your Linux system. It describes how the installation script works
and how it can be used to either install the sk98lin driver or to 
create a Linux kernel patch. The installation script can be used on
Linux kernel versions 2.6 and higher.

Applying the Linux kernel patch requires an installed Linux kernel 
which can be compiled and which is used along with the applied 
sk98lin driver. Therefore, unpacking, patching, configuring,
and compiling a Linux kernel is also explained in this document.

This document does not describe the sk98lin driver and its 
parameters. For more information refer to 'sk98lin.txt' or 
the sk98lin.4 man page.
***


2  Required Files and Tools
===========================

To install the sk98lin driver the following files
and tools on your Linux system are required:

- Linux kernel source available in directory /usr/src/linux

- Compiler tools (e.g. gcc)
***


3  Prerequisites
================

The prerequisites for compilation, loading, and patch creation of the
sk98lin driver are:

- Any device using the sk98lin kernel module needs to be closed.

- The old sk98lin kernel module needs to be unloaded.
  Per default the installation script will do this automatically
  (if "installation" mode is selected). 

- Your system has to be equipped with a supported network controller. 
  Without a network controller the full driver functionality cannot be checked.

- The kernel source used for compilation and the running kernel
  have to be consistent (same version and same configuration).
***


4  Preparing the Driver Installation Package
============================================

Before the sk98lin driver installation script can be invoked, the 
installation package needs to be unpacked:

1.  Login as 'root'.

2.  To unpack the driver installation package, execute the command

    # tar xfvj install_A.B.C.D.tar.bz2
    or
    # bunzip2 -c install_A.B.C.D.tar.bz2 | tar xfv -
***

5  Driver Installation
======================

1. After the driver installation package is unpacked, execute the following
   commands to start the sk98lin driver build process:

   # cd DriverInstall
   # ./install.sh

2. Select the driver installation mode (see following sections).

NOTE: In case you have installed another driver module than the original
      Marvell driver you will be asked how to further proceed. You can
      ignore the fact, you can rename the other driver, or you can erase
      the driver. We recommend to erase the driver to avoid unwanted
      side effects and interdependencies.

3. Wait for the driver build process to finish.
   Depending on the installation mode you selected, the driver is either 
   compiled and installed, or a kernel patch is generated.

NOTE:
Depending on your Linux distribution, the name of your device may have
changed after successful installation. In order to restore your old 
device, start the appropriate network configuration utility and rename 
the device.
***

5.1  Installation Mode
----------------------

When selecting the installation mode, the driver sources shipped
with the install package are compiled and the resulting driver 
module object file is installed to a suitable location (usually somewhere
below directory /lib/modules/...).

No source files of the driver are installed into a kernel directory.
Only the driver module object file and the man page of the driver are 
installed onto your system permanently. 
            
Installation mode means that the build process runs automatically 
without any user interaction. In case of installation problems, 
the driver installation script autonomously tries to solve the problem 
(if possible). 

After the compilation has finished, the initial system state and 
configuration is recovered and all (possibly) backed-up system 
files are restored from the initial configuration.
***

5.2  Patch Generation Mode
--------------------------

When selecting the patch generation mode, a driver patch is created 
which can be applied to your Linux kernel (instead of compiling and 
installing the driver on your system).

Usually, a patch is applied when a recompilation of the Linux
kernel is intended and the latest driver sources need to be
installed permanently in the appropriate driver directory of 
the Linux kernel.

NOTE: You still have to compile your patched Linux kernel in
      order to effectively use the latest driver sources shipped 
      with this installation package! 
***

5.3  Generate Makefile Mode
---------------------------

When selecting the generate makefile mode, all of the driver sources including 
a makefile will be copied into a new "src" directory.

Usually, the generate makefile mode is used by experienced users to compile 
the driver sources for development purposes without compiling the whole 
linux kernel.

***

6  Patch Generation and Recompilation of the Kernel
===================================================

If a new patch has been created using the sk98lin driver installation 
script, 
- it needs to be applied to the Linux kernel sources 
and 
- the Linux kernel has to be recompiled in order to use the 
  sk98lin driver.
***

6.1  Downloading and Unpacking the Linux Kernel
-----------------------------------------------

Before the sk98lin driver installation script is used to generate
a driver patch, a Linux kernel needs to be installed. If you already have 
installed a Linux kernel in the directory /usr/src, you can skip this
section and continue with the section "Applying the Driver Patch".

To patch the Linux Kernel:

1.  Login as 'root'.

2.  Download the original Linux source code named linux-a.b.c.tar.bz2
    from ftp.kernel.org into the directory /usr/src

3.  Go to the directory /usr/src and remove all symbolic links to old 
    Linux sources executing the commands:

    # cd /usr/src
    # rm linux

4.  Unpack the original Linux source code executing the command:

    # tar xvjf linux-a.b.c.tar.bz2

    After the sources have been installed, they can be found in a
    directory named /usr/src/linux-a.b.c or /usr/src/linux.

5.  If the symbolic link to the target kernel source directory 
    (/usr/src/linux) does not exist, create it manually with the 
    following commands:

    # cd /usr/src
    # ln -s linux-a.b.c linux
***

6.2  Generating the Driver Patch
--------------------------------

To generate the driver patch:

1. Start the sk98lin driver installation script.

2. Select "generate patch".

3. Follow the instructions of the installation script.
***

6.3  Applying the Driver Patch
------------------------------

To apply the generated patch into the kernel, execute the following
commands:
    
# cd /usr/src/linux
# cat /patch-location/sk98lin__vA.B.C.D_a.b.c_patch | patch -p1
***

6.4  Configuring the Linux Kernel
---------------------------------

To configure the Linux Kernel:

1.  Go to the directory /usr/src/linux:

    # cd /usr/src/linux

2.  Depending on your current environment mode (console or graphical),
    you have to invoke different Kernel configuration commands:

    In the console mode, execute the command: 

    # make menuconfig

    In the graphical mode, execute the command:

    # make xconfig
    
    or

    # make gconfig

    This builds a few programs and displays the kernel configuration menu. 

3.  Select the menu "device drivers".

4.  Select the menu "Network Device Support".

5.  Select "Ethernet (1000 Mbit)".

6.  To compile the driver as a module, mark 
    "Marvell Yukon Chipset/SysKonnect SK-98xx Support" with (M).

    To integrate the driver permanently into the kernel, mark 
    "Marvell Yukon Chipset/SysKonnect SK-98xx Support" with (*).

7.  To enable Rx polling of the driver, mark
    "Use Rx polling (NAPI)" with (*).

8.  Select "Exit".

9.  Select the menu "Loadable module support".

10.  Select "Enable loadable module support".

11.  Select "Kernel module loader".

12. Configure other options, e.g., SCSI, file systems, etc.

13. To quit the configuration, select "Exit".

14. When the message "Do you wish to save your new kernel configuration"
    is displayed, select "Yes".
***

6.5  Compiling and Installing the Linux Kernel
----------------------------------------------

To compile and install the Linux kernel: 

1.  Build the Linux kernel binary. Build all modules and install them 
    below /lib/modules by executing the commands: 

    # make        
    # make modules_install
    # make install

2.  Reboot your system with the new kernel.
***
7  Generate Makefile Mode
=========================

If generate makefile mode has been selected using the sk98lin driver 
installation script, the sk98lin driver sources will be compiled using 
the running kernel and the driver binary will be generated in the "src" 
directory.
In this case the Linux kernel will not be recompiled.

To use generate makefile mode:

1. Start the sk98lin driver installation script.

2. Select "generate makefile".

3. Follow the instructions of the installation script.
***

8  Manual Module Loading
========================

After booting the Linux kernel and compiling the driver as a loadable 
kernel module (LKM), the driver needs to be loaded:

1. Enter "modprobe sk98lin".

2. Execute the command "ifconfig ethX <IP_Adr.>":

  # ifconfig eth0 192.168.0.1
  # ifconfig eth1 192.168.1.1
   
NOTE: For further information (e.g. the driver parameters) refer to 
      the sk98lin.txt file.
***


9  Unloading the Module
=======================

Unloading of the sk98lin driver is only possible if it has been 
compiled as a loadable kernel module. Before the driver module can be 
unloaded, all interfaces of the driver module must to be stopped with 
the following sequence of commands:

1. Execute the command "ifconfig YOUR_DEVICE down":

  # ifconfig eth0 down
  # ifconfig eth1 down
  # ifconfig ... down

2. Execute the command "rmmod sk98lin".
***


10  Driver Parameters
=====================

When loading the driver as a kernel module, additional parameters
can be passed to the driver for configuration.

The parameters can be passed in two ways: 

State them on the modprobe command line.
or
Set them in the file /etc/modprobe.conf (old name: 
/etc/modules.conf), in order to force the kernel module loader
to pass them to the driver at load-time.

NOTE: For further information about the driver parameters and their
      possible values refer to the sk98lin.txt file.
***


11  Ethtool Commands
====================

The sk98lin driver provides built-in ethtool support. The ethtool 
can be used to display or modify interface specific configurations.

NOTE: For further information about the ethtool commands and their
      possible values refer to the sk98lin.txt file.
***


12  Troubleshooting
===================

If any problems occur during the installation process, check the 
following list of known problems. If you cannot find your problem 
in the list below, contact Marvell technical support
for help (MSGG-linux@marvell.com). When contacting our technical 
support, ensure that the following information is available:

- The 'install.log' file created by the install script 'install.sh'
- System Manufacturer and HW Informations (CPU, Memory... )
- PCI-Boards in your system
- Distribution
- Kernel version
- Driver version

Problem:  Programs such as 'ifconfig' or 'route' cannot be found or the 
          error message 'Operation not permitted' is displayed.
Reason:   You are not logged in as user 'root'.
Solution: Logout and login as 'root' or change to 'root' via 'su'.


Problem:  The driver can be started, but if an ip address is assigned
          to a network controller no link up indication is displayed although
          it is connected to the network. It is also not possible to receive
          or transmit any packets, i.e., 'ping' does not work.
Reason:   The network controller does not receive any interrupts from the Linux 
          system. This can happen when using the APIC (Advanced 
          Programmable Interrupt Controller) of an SMP (Symmetric Multi-Processor)
          compiled kernel in a UP (Uni-Processor) environment. 
Solution: Use the Linux kernel parameters 'noapic' or 'nolapic' when
          booting the kernel. To do this, add these kernel parameters
          to the boot manager kernel selection menu (either
          /boot/grub/menu.lst for GRUB or /etc/lilo.conf for LILO).
          When you build a kernel, deselect the option CONFIG_X86_LOCAL_APIC.


Problem:  The driver can be started, the network controller is connected to the 
          network and a link up indication is displayed, but you cannot 
          receive or transmit any packets, e.g., 'ping' does not work.
Reason:   There is an incorrect route in your routing table or the
          remote host is unreachable.
Solution: Check the routing table with the command 'route' and read the 
          man pages dealing with routes (enter 'man route').
          Check the connection to the remote host system.
		  
Problem:  After running the "install.sh" script the error message 
          './functions: 44: Syntax error: "(" unexpected' is displayed.
Reason:   Your Linux sytem uses a Debian Almquist shell (dash) which is a Unix 
          shell and much smaller than bash but still aiming at POSIX-compliancy. 
	    It requires less disk space but is also less feature-rich.
Solution: Use the following command: 'sudo bash ./install.sh'.

***


***End of Readme File***
