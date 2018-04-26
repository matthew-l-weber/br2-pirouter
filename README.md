# br2-pirouter
Raspberry Pi-based router, firewall, and access point.

## Overview
This repository contains a so-called *external tree* for using with
Buildroot. With the help of the latter, it produces a minimalistic
embedded Linux system, configured to work as a router, a stateful
firewall, and a wireless access point.

## Hardware
The system runs on Raspberry Pi models 1 and 2, equipped with a Realtek
rtl8188eu Wi-Fi USB dongle, and with an external Ethernet switch capable
of 802.1q VLAN tagging.

## Kernel
The kernel supports the essential hardware only, and its feature set is
reduced almost to the bare minimum. Here are some of its peculiarities:

* No support for block devices and file systems (except for initramfs),
* No support for UIDs other than 0,
* No I/O devices except the serial console.

Another notable feature is that the kernel is configured to be
multiplatform, i.e. able to work without change on both ARMv6 (RPi1) and
ARMv7 (RPi2). All platform-dependent settings are taken from a device
tree blob.

## Init
All traditional init systems are too complicated for this system. Our
`/init` is a simple shell script which mounts pseudo file systems,
starts networking in background, and then keeps the shell always
available on the console.

## File system
The root file system is kept in initramfs and is therefore volatile.
Since the kernel has no support for block devices, it cannot access the
SD card it was booted from, so to make a permanent change in the
configuration you have to rebuild the image. Not very convenient,
perhaps, but secure and funny.

## The C library
The system uses `uClibc` as its C library. The features of the library
are also reduced to a minimum. For example, it has no support for
threads.

## Userspace programs
Most essential programs are provided by `busybox`. The others are:

* `hostapd`
* `radvd`
* `xl2tpd` and `pppd`
* `iptables` and `ip6tables`
* `tcpdump`
* `sit-ctl`

System log is kept in a circular memory buffer.

## Configuration files
At build time, the configuration files and scripts in `/etc` are
generated from templates using settings in `board/overlay.tmpl`.

## Examples
Size of the compressed images:

    -rw-r--r-- 1 alexandr1 adm 2252329 Apr 26 17:11 rootfs.cpio.gz
    -rw-r--r-- 1 alexandr1 adm 1658216 Apr 26 17:11 zImage


Process list of a live system:

    ~ # ps | grep -vw 0
      PID USER       VSZ STAT COMMAND
        1 root      1096 S    {init} /bin/sh /init
       25 root      1096 S    sh
       27 root      1088 S    klogd
       29 root      2112 S    syslogd -C1024
       52 root      1092 S    telnetd
       82 root      1940 S    hostapd -B /etc/hostapd.conf
       84 root      1092 S    udhcpd -S
       94 root      1092 S    udhcpc -i man -s /etc/udhcpc-hook.sh -S -R
       97 root       888 S    xl2tpd -c /etc/xl2tpd.conf -C /var/run/l2tp-control
       99 root       848 S    radvd -p /var/run/radvd.pid
      100 root       848 S    radvd -p /var/run/radvd.pid
      101 root      1384 S    /usr/sbin/pppd plugin pppol2tp.so pppol2tp 7 passive nodetach : file
      113 root      1096 S    -sh
      117 root      1092 R    ps
    ~ #

## Build
This tree is compatible with the current `master` Buildroot branch.

## License
All works by me are in the public domain.

For the licensing of the output binary image, consult the Buildroot
documentation.
