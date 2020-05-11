#!/bin/bash
source helper_functions.sh
is_sudo_exec

HOST_ADDR=$(hostname -I | awk '{print $1}')
SSL_DIR="/tmp/.ssh"
PY_TEMP="/tmp/temp.py"
JUPYTER_CFG="/home/ubuntu/.jupyter/jupyter_notebook_config.py"
JUPYTER_CFG="/Users/ym186017/.jupyter/jupyter_notebook_config.py"
JUPYTER_PASSWD=$1

while [ -z "$JUPYTER_PASSWD" ]
do
    echo -n "Enter JUPYTER password: "
    read JUPYTER_PASSWD
done

echo "Updating software repositories..."
apt-get -y update
echo "Done!"

echo ""

echo "Installing python package manager..."
sudo apt-get -y install python3-pip
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
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "${SSL_DIR}/cert.key" -out "${SSL_DIR}/cert.pem" -batch
echo "Done!"

echo ""

echo "Creating Jupyter Defailt Config..."
#jupyter notebook --generate -y
echo "Done!"
echo "Updating Jupyter Defailt Config (${JUPYTER_CFG})..."
cp $JUPYTER_CFG $PY_TEMP
upsert_line $PY_TEMP "c.NotebookApp.password" $SHA1 ' = '
upsert_line $PY_TEMP "c.NotebookApp.ip" $HOST_ADDR ' = '
upsert_line $PY_TEMP "c.NotebookApp.notebook_dir" $JUPYTER_CFG ' = '
upsert_line $PY_TEMP "c.NotebookApp.certfile" "${SSL_DIR}/cert.pem" ' = '
upsert_line $PY_TEMP "c.NotebookApp.keyfile" "${SSL_DIR}/cert.key" ' = '
echo "Done!"

