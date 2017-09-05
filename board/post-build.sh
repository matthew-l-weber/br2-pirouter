#!/bin/sh

ovl=$2/board/overlay
tmpl=$2/board/overlay.tmpl

# Remove unnecessary files
cd $TARGET_DIR
rm -rvf media mnt opt lib32
rm -rvf usr/share/udhcpc
rm -rvf var/www
cd etc
rm -rvf profile* fstab mtab network
cd ../usr/bin
rm -vf pfc pon poff hostapd_cli
cd ../sbin
rm -vf chat pppdump pppoe-discovery pppstats radvdump xl2tpd-control

# Perform template substitution
cd $TARGET_DIR
(cd $ovl; find . -type f) | xargs -t -L 1 sed -f $tmpl -i
