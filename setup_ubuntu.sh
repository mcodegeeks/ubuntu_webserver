#!/bin/bash
source setup_common.sh
is_sudo_exec

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

echo ""

echo "Updating software repositories..."
apt -y update
echo "Done!"

echo ""

echo "Installing prerequisite packages..."
apt -y install apt-transport-https ca-certificates curl software-properties-common
echo "Done!"

echo ""

echo "Adding GPG key for the official docker repository..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "Done!"

echo ""

echo "Adding the docker repository to APT source..."
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
echo "Done!"

echo "Update the package database with the docker packages..."
apt -y update
echo "Done!"

echo ""

echo "Installing from the docker repo instead of the default Ubuntu repo..."
apt-cache policy docker-ce
echo "Done!"

echo "Installing docker ce..."
apt -y install docker-ce
echo "Done!"

echo ""

echo "Installing docker compose..."
apt -y install docker-compose
echo "Done!"

echo ""

echo "Adding ${WORK_USER} user in the docker group..." 
usermod -aG docker $WORK_USER
echo "Done!"

echo ""

echo "Adding web working directory and group (${WORK_USER}:${WORK_GROUP} ${WORK_DIR})..."
groupadd $WORK_GROUP
usermod -aG $WORK_GROUP $WORK_USER
mkdir -p "${WORK_DIR}"
chown -R "${WORK_USER}:${WORK_GROUP}" ${WORK_DIR}
chmod 2775 $WORK_DIR
find $WORK_DIR -type d -exec chmod 2775 {} +
find $WORK_DIR -type f -exec chmod 0664 {} +
ln -fs "$(pwd)/html" ${WORK_DIR}
echo "Done!"
