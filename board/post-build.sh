#!/bin/sh

BOARD_DIR="$(dirname $0)"

ovl=$BOARD_DIR/overlay
tmpl=$BOARD_DIR/overlay.tmpl

# Remove unnecessary files
cd $TARGET_DIR
rm -rvf media mnt opt run
rm -rvf usr/share/udhcpc
cd etc
rm -rvf mtab network profile*
cd ../usr/bin
rm -vf pfc pon poff hostapd_cli
cd ../sbin
rm -vf chat pppdump pppoe-discovery pppstats radvdump xl2tpd-control

# Create /run and /var/run
cd $TARGET_DIR
mkdir -pv run var/run

# Perform template substitution
cd $TARGET_DIR
(cd $ovl; find . -type f) | xargs -t -L 1 sed -f $tmpl -i
