#!/bin/bash
source helper_functions.sh
is_sudo_exec

SSH_KEY="id_rsa"
SSH_DIR="/${USER}/.ssh"
SSH_CFG="/etc/ssh/sshd_config"
TIME_ZONE="America/Toronto"
SWAP_FILE="/var/swapfile"
FSTAB_FILE="/etc/fstab"

echo "Updating SSH config (${SSH_CFG})..."
upsert_line $SSH_CFG 'ClientAliveInterval' 60 ' '
echo "Done!"

echo "Restarting SSH demon..."
service sshd restart
echo "Done!"

echo ""

echo "Generating SSH key pair..."
mkdir -p $SSH_DIR
if [ -f "${SSH_DIR}/${SSH_KEY}" ]; then
    echo "SSH Key pair already exists"
else
    ssh-keygen -t rsa -f "${SSH_DIR}/${SSH_KEY}" -q -N ""
fi
cat "${SSH_DIR}/${SSH_KEY}.pub"
echo "Done!"

echo ""

echo "Updating time zone..."
timedatectl set-ntp yes
timedatectl set-timezone $TIME_ZONE
timedatectl
echo "Done!"

echo ""

echo "Enabling swap file..."
if [ -f "${SWAP_FILE}" ]; then
    echo "Swap file already exists"
else
    dd if=/dev/zero of=$SWAP_FILE bs=1M count=4096
    chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon $SWAP_FILE
    echo "${SWAP_FILE}   swap    swap    defaults        0   0" | tee -a $FSTAB_FILE > /dev/null
    swapon -a
    swapon --show
fi
echo "Done!"
