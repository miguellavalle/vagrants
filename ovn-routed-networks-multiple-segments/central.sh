#!/usr/bin/env bash
set -x

hostname=$(hostname)
segment=$1

DEBIAN_FRONTEND=noninteractive sudo apt-get update -qqy 
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -qqy 

git clone https://opendev.org/openstack/devstack.git ~/devstack
cp /vagrant/local.conf.central /home/vagrant/devstack/local.conf
cd /home/vagrant/devstack
sed -i '/ADMIN_PASSWORD/a\STACK_USER=vagrant' /home/vagrant/devstack/local.conf
sed -i 's/ERROR_ON_CLONE=.*/ERROR_ON_CLONE="False"/' /home/vagrant/devstack/local.conf
sed -i 's/HOST_IP=.*/HOST_IP="'${central}'"/' /home/vagrant/devstack/local.conf
sed -i 's/SERVICE_HOST=.*/SERVICE_HOST="'${central}'"/' /home/vagrant/devstack/local.conf
sudo chown vagrant:vagrant /opt
./stack.sh
sudo cp /vagrant/rsyncd.conf /etc/.
sudo systemctl start rsync
sudo systemctl enable rsync
sudo ovs-vsctl set open . external-ids:ovn-bridge-mappings="${segment}:br-ex"
sudo ovs-vsctl add-port br-ex eth2
