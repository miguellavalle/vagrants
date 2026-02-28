#!/usr/bin/env bash
set -x

hostname=$(hostname)

DEBIAN_FRONTEND=noninteractive sudo apt-get update -qqy 
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -qqy 

sudo modprobe 8021q

sudo ip link set dev eth2 up
sudo ip link add link eth2 name eth2.100 type vlan id 100
sudo ip addr add 172.24.4.1/24 dev eth2.100
sudo ip link set dev eth2.100 up
sudo ip link add link eth2 name eth2.300 type vlan id 300
sudo ip addr add 172.24.8.1/24 dev eth2.300
sudo ip link set dev eth2.300 up

sudo ip link set dev eth3 up
sudo ip link add link eth3 name eth3.200 type vlan id 200
sudo ip addr add 172.24.6.1/24 dev eth3.200
sudo ip link set dev eth3.200 up
sudo ip link add link eth3 name eth3.400 type vlan id 400
sudo ip addr add 172.24.12.1/24 dev eth3.400
sudo ip link set dev eth3.400 up

sudo iptables -A FORWARD -i eth2.100 -o eth3.200 -j ACCEPT
sudo iptables -A FORWARD -i eth2.100 -o eth3.300 -j ACCEPT
sudo iptables -A FORWARD -i eth2.100 -o eth3.400 -j ACCEPT

sudo iptables -A FORWARD -i eth3.200 -o eth2.100 -j ACCEPT
sudo iptables -A FORWARD -i eth3.200 -o eth2.300 -j ACCEPT
sudo iptables -A FORWARD -i eth3.200 -o eth2.400 -j ACCEPT

sudo iptables -A FORWARD -i eth3.300 -o eth2.100 -j ACCEPT
sudo iptables -A FORWARD -i eth3.300 -o eth2.200 -j ACCEPT
sudo iptables -A FORWARD -i eth3.300 -o eth2.400 -j ACCEPT

sudo iptables -A FORWARD -i eth3.400 -o eth2.100 -j ACCEPT
sudo iptables -A FORWARD -i eth3.400 -o eth2.200 -j ACCEPT
sudo iptables -A FORWARD -i eth3.400 -o eth2.300 -j ACCEPT

sudo sysctl -w net.ipv4.ip_forward=1
