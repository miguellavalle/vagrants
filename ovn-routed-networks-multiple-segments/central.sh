#!/usr/bin/env bash
set -x

hostname=$(hostname)
segment_1=$1
vlan_id_1=$2

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
sudo ovs-vsctl set open . external-ids:ovn-bridge-mappings="${segment_1}:br-ex-${vlan_id_1}"

# Delete created by devstack flat public network
set +x
source ~/devstack/openrc admin admin
set -x
openstack router unset --external-gateway router1
openstack router show router1 -c interfaces_info -f yaml | grep port_id | awk {'print $2'} | xargs -I% openstack router remove port router1 %
openstack router delete router1
openstack network delete public

# Delete unused networks and security groups
openstack network delete shared
openstack network delete private
openstack security group list -c ID -f value  | xargs openstack security group delete

# Add new vlan mappings
iniset /etc/neutron/plugins/ml2/ml2_conf.ini  ml2_type_vlan network_vlan_ranges segment-1-net-1:4000:4094,segment-1-net-2:4000:4094
sudo systemctl restart devstack@neutron-api.service
sleep 10

# Set up segment bridges and patch ports
sudo ovs-vsctl add-br br-ex-${vlan_id_1}
sudo ovs-vsctl \
	-- add-port br-ex patch-ex-${vlan_id_1} \
	-- set interface patch-ex-${vlan_id_1} type=patch options:peer=patch-${vlan_id_1}-ex \
	-- add-port br-ex-${vlan_id_1} patch-${vlan_id_1}-ex \
	-- set interface patch-${vlan_id_1}-ex type=patch options:peer=patch-ex-${vlan_id_1}
sudo ovs-vsctl set Port patch-ex-${vlan_id_1} vlan_mode=access tag=${vlan_id_1}
sudo ovs-vsctl add-port br-ex eth2
sudo ovs-vsctl set Port eth2 vlan_mode=trunk trunks=100,200

cp /vagrant/.vimrc ~/.
cp /vagrant/.editorconfig /opt/stack/neutron/.
