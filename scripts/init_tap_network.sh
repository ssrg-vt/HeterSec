#!/bin/bash

## Check parameters
if  [ "$#" -ne 1 ]; then
	echo "Usage: $0 <NIC name>"
	exit 1
fi

ip link show | grep $1:  &> /dev/null 
nic=$(echo $?)
if [ $nic -ne 0 ]; then
	echo "Usage: $0 <NIC name> (e.g., $0 eth0)"
	exit 1
fi

## Check whether tap0/tap1 exist
ip link show | egrep "tap0|tap1"  &> /dev/null
tap_exist=$(echo $?)
if [ $tap_exist -eq 0 ]; then
	echo "tap0/tap1 already exist .."
	exit 1
fi

## Set up tap0/tap1, iptables, ip forward
echo "Setting up tap0 .."
sudo ip tuntap add mode tap tap0
sleep 1
sudo ip addr add 10.2.0.1/24 dev tap0
sleep 1
sudo ip link set tap0 up

echo "Setting up tap1 .."
sudo ip tuntap add mode tap tap1
sleep 1
sudo ip addr add 10.2.1.1/24 dev tap1
sleep 1
sudo ip link set tap1 up

echo "Setting up the iptables rule .."
sudo iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE

echo "Enable ip forward .."
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

