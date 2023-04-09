#!/bin/bash

if [[ $EUID > 0 ]]
  then echo "Run this script as root"
  exit
fi

BRIDGE="br0"
TAP="tap0"
INTERFACE="eth0"

echo "Removing master of $TAP"
ip link set $TAP nomaster

echo "Deleting $TAP"
ip tuntap del $TAP

echo "Removing master of $INTERFACE"
ip link set $INTERFACE nomaster

echo "Setting $BRIDGE down"
ip link set down dev $BRIDGE

echo "Deleting $BRIDGE"
ip link del $BRIDGE

echo "Setting $INTERFACE up"
ip link set up dev $INTERFACE

killall qemu-system-aarch64
