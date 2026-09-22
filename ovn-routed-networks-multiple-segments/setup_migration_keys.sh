#!/bin/bash
# Run this script as root!

## Define your nodes here
NODES=("central" "worker1" "worker2" "worker3")
VAGRANT_PASS="vagrant" # The default vagrant user password

# 1. Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (sudo su -)"
    exit 1
fi

# 2. Generate root SSH key if it doesn't already exist
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating SSH key for root..."
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
fi

# 3. Install sshpass if missing (to automate the password prompt)
if ! command -v sshpass &> /dev/null; then
    echo "Installing sshpass..."
    # Works for Ubuntu/Debian or CentOS/RHEL
    apt-get update -qq && apt-get install -y sshpass || yum install -y sshpass
fi

# 4. Distribute the key to the vagrant user on all other nodes
for NODE in "${NODES[@]}"; do
    # Skip the node we are currently running on
    if [ "$NODE" != "$(hostname)" ]; then
        echo "Pushing root key to vagrant@$NODE..."

        # ssh-copy-id automatically appends the key to authorized_keys
        sshpass -p "$VAGRANT_PASS" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519.pub vagrant@$NODE

        # Verify the tunnel
        ssh -o StrictHostKeyChecking=no vagrant@$NODE "echo '  -> Success! Root tunnel to $NODE is open.'"
    fi
done

echo "All live migration SSH tunnels are configured!"
