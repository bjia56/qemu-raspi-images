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

#echo "Adding bridge $BRIDGE"
#ip link add name $BRIDGE type bridge
#
#echo "Setting $BRIDGE as master of $INTERFACE"
#ip link set $INTERFACE master $BRIDGE
#
#echo "Adding tap $TAP"
#ip tuntap add $TAP mode tap
#
#echo "Setting $BRIDGE as master of $TAP"
#ip link set $TAP master $BRIDGE
#
#echo "Setting $BRIDGE IP to $BRIDGE_IP"
#ip addr add $BRIDGE_IP dev $BRIDGE
#
#echo "Setting $INTERFACE, $BRIDGE and $TAP up"
#ip link set up dev $INTERFACE
#ip link set up dev $TAP
#ip link set up dev $BRIDGE
#
#echo "Printing interfaces and routes"
#ip addr
#ip route
#
#echo "Adding iptables rules"
#iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
#iptables -P FORWARD ACCEPT

echo "Starting QEMU"
#qemu-system-aarch64 \
#    -M raspi3b \
#    -cpu max \
#    -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1 net.ifnames=0 biosdevname=0" \
#    -dtb bcm2710-rpi-3-b-plus.dtb \
#    -drive if=sd,index=0,file=raspi.img,format=raw \
#    -kernel kernel8.img \
#    -m 1G -smp 4 \
#    -serial stdio \
#    -usb -device usb-net,netdev=net0 \
#    -netdev user,id=net0,hostfwd=tcp::5555-:22 \
#    -enable-kvm \
#    -display none
truncate -s 64m varstore.img
truncate -s 64m efi.img
dd if=/usr/share/qemu-efi-aarch64/QEMU_EFI.fd of=efi.img conv=notrunc
qemu-system-aarch64 -M virt  \
      -machine virtualization=true -machine virt,gic-version=3  \
      -cpu max,pauth-impdef=on -smp 2 -m 1G           \
      -drive if=pflash,format=raw,file=efi.img,readonly=on      \
      -drive if=pflash,format=raw,file=varstore.img         \
      -drive if=virtio,format=qcow2,file=raspi.img           \
      -device virtio-scsi-pci,id=scsi0              \
      -object rng-random,filename=/dev/urandom,id=rng0      \
      -device virtio-rng-pci,rng=rng0               \
      -device virtio-net-pci,netdev=net0                \
      -netdev user,id=net0,hostfwd=tcp::5555-:22            \
      -nographic                            \
      -display none
