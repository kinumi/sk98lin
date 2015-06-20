sk98lin
=======

Unofficial version of sk98lin which is Marvell Yukon/SysKonnect SK-98xx Gigabit Ethernet Adapter driver for Linux. (http://www.marvell.com/support/downloads/)

Official version can be compiled only in the kernel 2.6.X. This version is modified to be able to compile in Kernel 3.19.X.


## !!! IMPORTANT !!!

- I am unrelated to Marvell. 
- I am not a driver engineer. 
- Any warranty is nothing.
- Just worked. Not fully tested :)


## Worked Environment

### HW

- VAIO type P (88E8057 PCI-E Gigabit Ethernet Controller)

### OS

- Ubuntu 15.04 (Kernel 3.19.X)
- Ubuntu 14.04 (Kernel 3.16.X)


## Install Instructions

### Pre-requires

```bash:command
$ sudo apt-get install git build-essential linux-headers-`uname -r`
```

### Build

```bash:command
$ cd /tmp
$ git clone git clone https://github.com/kinumi/sk98lin.git
$ cd sk98lin/sk98lin
$ tar xvfj ../sk98lin.tar.bz2 *
$ cd ..
$ sudo -s
# export IGNORE_SKAVAIL_CHECK=1
# bash install.sh -m
# export CONFIG_SK98LIN=m
# make  CC=cc KBUILD_OUTPUT=/lib/modules/`uname -r`/build -C /lib/modules/`uname -r`/build SUBDIRS=/tmp/sk98lin/src
```

### Install

```bash:command
# mkdir /lib/modules/`uname -r`/extra
# cp src/sk98lin.ko /lib/modules/`uname -r`/extra
# depmod
# rmmod sky2
# modprobe sk98lin
# echo "blacklist sky2" >>  /etc/modprobe.d/blacklist.conf
# update-initramfs -u -k all
# reboot
```

