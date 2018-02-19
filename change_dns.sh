#!/bin/bash

DNS="62.37.228.20"
DNS2="80.58.61.254"
USUARIO=$(whoami)
ROOT=root

if [ $USUARIO == $ROOT ]; then
	echo nameserver $DNS > /etc/resolv.conf 
	echo nameserver $DNS2 >> /etc/resolv.conf 
	exit 0
else
	echo -e "\e[31mejecutar como ROOT"
	echo -e "\033[0m"
	read 
	exit 1
fi
