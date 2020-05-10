#!/bin/bash

#HOST_ADDR=$(hostname -I | awk '{print $1}')
SSL_DIR="/tmp/.ssh"
PY_TEMP="/tmp/temp.py"
JUPYTER_CFG="/home/ubuntu/.jupyter/jupyter_notebook_config.py"
JUPYTER_PASSWD=$1

source helper_functions.sh
#checkScriptPermission

while [ -z "$JUPYTER_PASSWD" ]
do
    echo -n "Enter JUPYTER password: "
    read JUPYTER_PASSWD
done

echo "Updating software repositories..."
#apt-get -y update
echo "Done!"

echo ""

echo "Installing python package manager..."
#sudo apt-get -y install python3-pip
echo "Done!"

echo ""

echo "Installing Jupyter Notebook..."
pip3 install notebook
echo "Done!"

echo ""

echo "Creating SHA1 hash value..."
echo "from notebook.auth import passwd" > $PY_TEMP
echo "sha1=passwd('${JUPYTER_PASSWD}')" >> $PY_TEMP
echo "print(sha1)" >> $PY_TEMP
SHA1=$(python3 $PY_TEMP)
echo $SHA1
rm $PY_TEMP
echo "Done!"

echo ""

echo "Creating SSL key-pair..."
mkdir -p $SSL_DIR
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$SSL_DIR/cert.key" -out "$SSL_DIR/cert.pem" -batch
echo "Done!"










#HOST_IP_ADDRESS=
#JUPYTER_CONFIG='/home/ubuntu/.jupyter/jupyter_notebook_config.py'
#JUPYTER_SERVICE='/etc/systemd/system/jupyter.service'
#TEMP_PY_FILE='/tmp/temp.py'
#SSL_DIR='/home/ubuntu/.ssh'

#if [ -z "$1" ]
#  then
#    USER_PASSWORD="password"
#    printf "User password input is recommened!!! (Default Password: %s)\n" $USER_PASSWORD
#fi
