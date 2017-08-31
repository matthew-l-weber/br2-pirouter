#!/bin/sh

cd $TARGET_DIR
rm -rvf media mnt opt lib32
rm -rvf usr/share/udhcpc
rm -rvf var/www
cd etc
rm -rvf profile* fstab mtab network
cd ../usr/bin
rm -vf pfc pon poff
cd ../sbin
rm -vf chat pppdump pppoe-discovery pppstats radvdump xl2tpd-control
