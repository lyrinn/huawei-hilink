#!/bin/sh

PATH=/opt/local/bin:/opt/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin
export PATH=${PATH}

iface=$(ip l |grep "enx.*BROAD.*state" | awk '{print $2}' | sed s/:$//)

if [ "X${iface}" = "X" ]
then
	echo "No modem interface found... bye :("
	exit 1
fi

state=$(ip link show ${iface} | awk '{print $9}')
if [ "X${state}" = "XDOWN" ]
then
	echo "Link with modem is down. Setting up..."
	ip link set ${iface} up
fi

ipaddr=$(ip a show ${iface} |grep "inet.*192\.168\.8\.*")
if [ "X$?" != "X0" ]
then
	echo "No IP address configured... Setting IP..."
	ip addr flush dev ${iface}
	ip addr add 192.168.8.88/24 dev ${iface}
fi
