#!/bin/sh

case $1 in
deconfig)	ip addr flush dev $interface
		cat /dev/null > /etc/resolv.conf
		;;
bound)		ip addr add $ip/$mask dev $interface
		ip rout add default via $router metric 256
		ip rout add $serverid via $router
		cat /dev/null > /etc/resolv.conf
		for s in $dns; do
			echo nameserver $s >> /etc/resolv.conf
		done
		;;
esac
