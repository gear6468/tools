#!/bin/bash

############################################
#										   #
# Add route for dynamic DNS IP through VPN #
#										   #
############################################

############################
# EDIT Hostname HERE:

HOST="yourhostname.net"

# USE "-v" option for verbose output

############################

D=0
if [ "x$1" = "x-v" ];
	then D=1
fi

LOOKUP="`which host`"
if [ "x$?" != "x0" ];
	then
		echo "host executable not found !"
		echo ">> install bind9-host package"
		exit 1
fi

DYN_IP="`$LOOKUP -4 $HOST`"
EC=$?
if [ $EC != 0 ];
	then 
		echo "Error: cannot resolve IP for '$HOST' !"
		echo ">> check hostname !"
		exit 2
	else
		DYN_IP="`echo $DYN_IP|cut -d\  -f4`"
		echo ">Host: '$HOST' has IP: $DYN_IP"
fi

TUN="`ip addr show dev tun0 |grep UP`"
EC=$?
if [ $D = 1 ]; then echo $TUN; fi
if [ $EC != 0 ];
	then 
		echo "Error: tun0 is not UP !"
		echo ">> check VPN connection !"
		exit 3
fi

# get VPN peer IP
IP=`ip addr show dev tun0 |grep inet\ |cut -d\  -f8|cut -d\/ -f1`

if [ $D = 1 ]; 
	then echo ">VPN peer IP: $IP"
fi

RCMD="ip route add $DYN_IP/32 via $IP dev tun0 proto static metric 0"
if [ $D = 1 ]; then echo $RCMD; fi

echo -n ">Adding route through VPN... "
ROUTE="`$RCMD`"
EC=$?
if [ $EC = 0 ];
	then
		echo "OK."
	else 
		echo "ERROR adding route !"
		echo ">> check if you have root permissions (i.e. run: sudo $0) OR if route already exists"
		exit 4
fi

#vim: filetype=sh
