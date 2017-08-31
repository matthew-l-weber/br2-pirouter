# br2-pirouter
Raspberry Pi-based router, firewall, and access point.

## Overview
This repository contains a so-called *external tree* for using with Buildroot. With the help of the latter, it produces a minimalistic embedded Linux system, configured to work as a router, stateful firewall, and a wireless access point.

## Kernel
The kernel supports the essential hardware only, and its feature set is reduced almost to the bare minimum. Here are some of its peculiarities:

* No support for block devices and file systems (except for initramfs),
* No support for UIDs other than 0,
* No input devices other than serial console.

Another notable feature is that the kernel is configured to be multiplatform, i.e. to work without change on both ARMv6 (RPi1) and ARMv7 (RPi2). All platform-dependent settings are taken from a device tree blob.

## Init
All traditional init systems are too complicated for this system. Here, `/init` is a simple shell script which mounts pseudo file systems, starts networking in background, and then keeps the shell always available on the console.

## File system
The root file system is kept in initramfs and therefore volatile. Since the kernel has no support for block devices, it cannot access the SD card it was booted from, so to make a permanent change in the configuration, you have to rebuild the image. Not very convenient, perhaps, but secure and funny.

## Standard C library
The system uses `uClibc` as its standard C library. The library is also stripped down as much as possible. Thus, support for threads has been ditched out, since no programs here require it.

## Userspace programs
Most essential programs are provided by `busybox`. Others are:

* `hostapd`
* `radvd`
* `xl2tpd` and `pppd`
* `iptables` and `ip6tables`
* `tcpdump`
* `sit-ctl`

System log is kept in a circular memory buffer.

## Configuration files
At build time, the configuration files and scripts in `/etc` are generated from templates using settings in `board/overlay.tmpl`.

## Examples
Size of the compressed images:

    -rw-r--r-- 1 alexandr1 adm 2427419 Aug 31 14:36 rootfs.cpio.gz
    -rw-r--r-- 1 alexandr1 adm 1640256 Aug 30 14:37 zImage

Process list of a live system:

    ~ # ps | grep -vw 0
      PID USER       VSZ STAT COMMAND
        1 root       940 S    {init} /bin/sh /init
       25 root       940 S    sh
       27 root       932 S    klogd
       29 root      1956 S    syslogd -C1024
       52 root       936 S    telnetd
       82 root      1040 S    hostapd_rtl -B /etc/hostapd_rtl.conf
       84 root       936 S    udhcpd -S
       94 root       936 S    udhcpc -i man -s /etc/udhcpc-hook.sh -S -R
       97 root       764 S    xl2tpd -c /etc/xl2tpd.conf -C /var/run/l2tp-control
       99 root       724 S    radvd -p /var/run/radvd.pid
      100 root       724 S    radvd -p /var/run/radvd.pid
      101 root      1256 S    /usr/sbin/pppd plugin pppol2tp.so pppol2tp 7 passive nodetach : file
      829 root       952 S    -sh
      900 root       936 R    ps
    ~ #

