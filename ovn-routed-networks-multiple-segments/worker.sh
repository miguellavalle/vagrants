#!/usr/bin/env bash
set -x

hostname=$(hostname)
physnet_1=$1
vlan_id_1=$2
physnet_2=$3
vlan_id_2=$4

sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get update -qqy

sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get upgrade -qqy \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold"

git clone https://github.com/openstack/devstack.git ~/devstack
cp /vagrant/local.conf.worker /home/vagrant/devstack/local.conf
cd /home/vagrant/devstack
sed -i '/ADMIN_PASSWORD/a\STACK_USER=vagrant' /home/vagrant/devstack/local.conf
sed -i 's/DATABASE_HOST=.*/DATABASE_HOST="'${central}'"/' /home/vagrant/devstack/local.conf
sed -i 's/ERROR_ON_CLONE=.*/ERROR_ON_CLONE="False"/' /home/vagrant/devstack/local.conf
sed -i 's/GLANCE_HOSTPORT=.*/GLANCE_HOSTPORT="'${central}':9292"/' /home/vagrant/devstack/local.conf
sed -i 's/HOST_IP=.*/HOST_IP="'${!hostname}'"/' /home/vagrant/devstack/local.conf
sed -i 's/Q_HOST=.*/Q_HOST="'${central}'"/' /home/vagrant/devstack/local.conf
sed -i 's/RABBIT_HOST=.*/RABBIT_HOST="'${central}'"/' /home/vagrant/devstack/local.conf
sed -i 's/SERVICE_HOST=.*/SERVICE_HOST="'${central}'"/' /home/vagrant/devstack/local.conf
sudo chown vagrant:vagrant /opt
sudo mkdir -p /opt/stack
sudo chown vagrant:vagrant /opt/stack
git clone https://github.com/openstack/neutron /opt/stack/neutron
git clone https://github.com/openstack/nova /opt/stack/nova
git clone https://github.com/openstack/neutron-tempest-plugin /opt/stack/neutron-tempest-plugin
git clone https://github.com/openstack/requirements /opt/stack/requirements
mkdir -p /opt/stack/data/CA
rsync -avz rsync://${central}/key/ca-bundle.pem /opt/stack/data
rsync -avz rsync://${central}/CA_data /opt/stack/data/CA
./stack.sh
sudo ovs-vsctl set open . external-ids:ovn-bridge-mappings="${physnet_1}:br-ex-${vlan_id_1},${physnet_2}:br-ex-${vlan_id_2}"

set +x
source ~/devstack/openrc admin admin
iniset /etc/neutron/plugins/ml2/ovn_agent.ini agent extensions metadata,segment_bridge
sudo systemctl restart devstack@q-ovn-agent.service
sleep 10

# Required to enable VM live migrations
sudo tee -a /etc/ssh/ssh_config > /dev/null << 'EOF'

Host worker* central
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    LogLevel QUIET
EOF

sudo ovs-vsctl add-port br-ex eth2
sudo ovs-vsctl set Port eth2 vlan_mode=trunk trunks=${vlan_id_1},${vlan_id_2}

curl -LsSf https://astral.sh/ruff/install.sh | sh
cd ~
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar xzf nvim-linux-x86_64.tar.gz
echo 'alias nvim="~/nvim-linux-x86_64/bin/nvim"' >> ~/.bashrc
cp /vagrant/.editorconfig /opt/stack/neutron/.
mkdir -p ~/.config/nvim
cp /vagrant/init.lua ~/.config/nvim/.
sudo apt install ripgrep -y
