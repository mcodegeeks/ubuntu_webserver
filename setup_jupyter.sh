#!/bin/bash
source setup_config.sh
source setup_helper.sh
is_sudo_exec

HOST_ADDR=$(hostname -I | awk '{print $1}')

JUPYTER_CFG="/home/ubuntu/.jupyter/jupyter_notebook_config.py"
JUPYTER_SERVICE="/etc/systemd/system/jupyter.service"
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
apt-get -y install python3-pip
echo "Done!"

echo ""

echo "Installing Jupyter Notebook..."
pip3 install notebook
echo "Done!"

echo ""

echo "Creating SHA1 hash value..."
rm -f $PY_TEMP
append_line $PY_TEMP "from notebook.auth import passwd"
append_line $PY_TEMP "sha1=passwd('${JUPYTER_PASSWD}')"
append_line $PY_TEMP "print(sha1)"
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
jupyter notebook --generate -y
echo "Done!"

echo "Updating Jupyter Defailt Config (${JUPYTER_CFG})..."
upsert_line $JUPYTER_CFG "c.NotebookApp.password" "u'${SHA1}'" ' = '
upsert_line $JUPYTER_CFG "c.NotebookApp.ip" "'${HOST_ADDR}'" ' = '
upsert_line $JUPYTER_CFG "c.NotebookApp.notebook_dir" "'/'" ' = '
upsert_line $JUPYTER_CFG "c.NotebookApp.certfile" "u'${SSL_DIR}/cert.pem'" ' = '
upsert_line $JUPYTER_CFG "c.NotebookApp.keyfile" "u'${SSL_DIR}/cert.key'" ' = '
echo "Done!"

echo ""

echo "Adding Jupyter as System Service ($JUPYTER_SERVICE)..."
rm -f $JUPYTER_SERVICE
append_line $JUPYTER_SERVICE "[Unit]"
append_line $JUPYTER_SERVICE "Description=Jupyter Notebook Server"
append_line $JUPYTER_SERVICE ""
append_line $JUPYTER_SERVICE "[Service]"
append_line $JUPYTER_SERVICE "Type=simple"
append_line $JUPYTER_SERVICE "User=ubuntu"
append_line $JUPYTER_SERVICE "ExecStart=/usr/bin/sudo /usr/local/bin/jupyter-notebook --allow-root --config=${JUPYTER_CFG}"
append_line $JUPYTER_SERVICE ""
append_line $JUPYTER_SERVICE "[Install]"
append_line $JUPYTER_SERVICE "WantedBy=multi-user.target"
systemctl daemon-reload
systemctl enable jupyter
systemctl restart jupyter
echo "Done!"
