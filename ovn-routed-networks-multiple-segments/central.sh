#!/usr/bin/env bash
set -x

hostname=$(hostname)
segment_1=$1
bridge_1=$2

DEBIAN_FRONTEND=noninteractive sudo apt-get update -qqy 
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -qqy 

git clone https://github.com/openstack/devstack.git ~/devstack
cp /vagrant/local.conf.central /home/vagrant/devstack/local.conf
cd /home/vagrant/devstack
sed -i '/ADMIN_PASSWORD/a\STACK_USER=vagrant' /home/vagrant/devstack/local.conf
sed -i 's/ERROR_ON_CLONE=.*/ERROR_ON_CLONE="False"/' /home/vagrant/devstack/local.conf
sed -i 's/HOST_IP=.*/HOST_IP="'${central}'"/' /home/vagrant/devstack/local.conf
sed -i 's/SERVICE_HOST=.*/SERVICE_HOST="'${central}'"/' /home/vagrant/devstack/local.conf
sudo chown vagrant:vagrant /opt
sudo mkdir -p /opt/stack
sudo chown vagrant:vagrant /opt/stack
git clone https://github.com/openstack/neutron /opt/stack/neutron
git clone https://github.com/openstack/nova /opt/stack/nova
git clone https://github.com/openstack/glance /opt/stack/glance
git clone https://github.com/openstack/keystone /opt/stack/keystone
git clone https://github.com/openstack/neutron-tempest-plugin /opt/stack/neutron-tempest-plugin
git clone https://github.com/openstack/placement /opt/stack/placement
git clone https://github.com/openstack/requirements /opt/stack/requirements
git clone https://github.com/openstack/tempest /opt/stack/tempest
./stack.sh
sudo cp /vagrant/rsyncd.conf /etc/.
sudo systemctl start rsync
sudo systemctl enable rsync
sudo ovs-vsctl set open . external-ids:ovn-bridge-mappings="${segment_1}:${bridge_1}"
sudo ovs-vsctl add-port br-ex eth2
