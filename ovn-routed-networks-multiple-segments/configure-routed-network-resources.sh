#!/usr/bin/env bash
source ~/devstack/openrc admin admin
set -x

# Discover all the hosts in the system
nova-manage cell_v2 discover_hosts

# Based on: https://docs.openstack.org/neutron/pike/admin/config-routed-networks.html
openstack network create --share --provider-physical-network segment-1-net-1 --provider-network-type vlan --provider-segment 100 public
openstack network segment set --name segment-1-net-1 $(openstack network segment list --network public -c ID -f value)
openstack network segment create --physical-network segment-1-net-2 --network-type vlan --segment 200 --network public segment-1-net-2
openstack subnet create --network public --network-segment segment-1-net-1 --ip-version 4 --subnet-range 172.24.4.0/24 --allocation-pool start=172.24.4.100,end=172.24.4.200 public-segment-1-net-1-v4
openstack subnet create --network public --network-segment segment-1-net-2 --ip-version 4 --subnet-range 172.24.6.0/24 --allocation-pool start=172.24.6.100,end=172.24.6.200 public-segment-1-net-2-v4

# Create security group that accepts ICMP and TCP
sg_id=$(openstack security group create -c id -f value sg-for-multisegment)
openstack security group rule create --protocol icmp ${sg_id}
openstack security group rule create --protocol tcp ${sg_id}


openstack server create --flavor m1.tiny --network public --availability-zone nova:central --image cirros-0.6.2-x86_64-disk --security-group sg-for-multisegment vm-central
openstack server create --flavor m1.tiny --network public --availability-zone nova:worker1 --image cirros-0.6.2-x86_64-disk --security-group sg-for-multisegment vm-worker1
openstack server create --flavor m1.tiny --network public --availability-zone nova:worker2 --image cirros-0.6.2-x86_64-disk --security-group sg-for-multisegment vm-worker2
openstack server create --flavor m1.tiny --network public --availability-zone nova:worker3 --image cirros-0.6.2-x86_64-disk --security-group sg-for-multisegment vm-worker3
sleep 60
openstack server list --long --column ID --column Name --column Status --column Networks --column Host

# To sniff packets sudo tcpdump -i eth2 -e -n -v
