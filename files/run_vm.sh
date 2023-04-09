#!/bin/bash

# networking adapted from https://gist.github.com/extremecoders-re/e8fd8a67a515fee0c873dcafc81d811c?permalink_comment_id=4328259#gistcomment-4328259
if [[ $EUID > 0 ]]
  then echo "Run this script as root"
  exit
fi

BRIDGE="br0"
TAP="tap0"
INTERFACE="eth0"
BRIDGE_IP="172.18.0.1/16"

echo "Adding bridge $BRIDGE"
ip link add name $BRIDGE type bridge

echo "Setting $BRIDGE as master of $INTERFACE"
ip link set $INTERFACE master $BRIDGE

echo "Adding tap $TAP"
ip tuntap add $TAP mode tap

echo "Setting $BRIDGE as master of $TAP"
ip link set $TAP master $BRIDGE

echo "Setting $BRIDGE IP to $BRIDGE_IP"
ip addr add $BRIDGE_IP dev $BRIDGE

echo "Setting $INTERFACE, $BRIDGE and $TAP up"
ip link set up dev $INTERFACE
ip link set up dev $TAP
ip link set up dev $BRIDGE

ip addr
ip route

iptables -t mangle -A PREROUTING -j MARK --set-mark 3 -p tcp -s $BRIDGE
iptables -t mangle -A PREROUTING -j MARK --set-mark 3 -p tcp -s $TAP
# Set default gateway as the proxy server in table 2
ip route add default via $INTERFACE table 2
# Forward traffic with mark 3 to table 2
ip rule add fwmark 3 table 2

#iptables -A FORWARD -i $BRIDGE -o $INTERFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
#iptables -A FORWARD -i $BRIDGE -o $INTERFACE -j ACCEPT
#iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE

qemu-system-aarch64 \
    -M raspi3b \
    -cpu cortex-a72 \
    -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1 net.ifnames=0 biosdevname=0" \
    -dtb bcm2710-rpi-3-b-plus.dtb \
    -drive if=sd,index=0,file=raspi.img,format=raw \
    -kernel kernel8.img \
    -m 1G -smp 4 \
    -serial stdio \
    -usb -device usb-mouse -device usb-kbd \
    -device usb-net,netdev=net0 \
    -netdev tap,id=net0,ifname=$TAP,script=no,downscript=no \
    -display none
