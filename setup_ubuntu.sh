#!/bin/bash

ROOT_UID=0
if [ ! $UID -eq $ROOT_UID ]; then
    echo "Execute this shell script with SUDO privilege!"
    exit 0
fi

SSH_KEY="id_rsa"
SSH_DIR="/${USER}/.ssh"
SSH_CFG="/etc/ssh/sshd_config"
TIME_ZONE="America/Toronto"
SWAP_FILE="/var/swapfile"
FSTAB_FILE="/etc/fstab"

function readConfig() {
    local file=$1
    local key=$2

    grep ".*${key}[ \t][ \t]*.*" $file | cut -d ' ' -f2
}

function writeConfig() {
    local file=$1
    local key=$2
    local val=$3

    grep ".*${key}[ \t][ \t]*.*" $file > /dev/null
    if [ ! "$?" -eq 0 ]; then
        echo "${key} ${val}" | tee -a $file > /dev/null
    else
       sed -ie "s/.*${key}[ \t][ \t]*.*/${key} ${val}/g" $file
    fi
}

function updateConfig() {
    local file=$1
    local key=$2
    local newVal=$3
    local oldVal=$(readConfig $file $key)
    if [ ! $newVal -eq $oldVal ]; then
        writeConfig $file $key $newVal
        newVal=$(readConfig $file $key)
        echo "ClientAliveInterval: ${newVal} (was ${oldVal})"
    else
        echo "ClientAliveInterval: ${oldVal}"
    fi
}

echo "Updating SSH config..."
updateConfig $SSH_CFG 'ClientAliveInterval' 60
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
