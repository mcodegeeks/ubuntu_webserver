# common
WORK_USER="ubuntu"
WORK_GROUP="www"
WORK_DIR="/var/www"

SSH_KEY="id_rsa"
SSH_DIR="/${USER}/.ssh"
SSH_CFG="/etc/ssh/sshd_config"

SSL_DIR="${SSH_CFG}"

TIME_ZONE="America/Toronto"

SWAP_FILE="/var/swapfile"
FSTAB_FILE="/etc/fstab"

PY_TEMP="/tmp/temp.py"

# For Jupyter
JUPYTER_CFG="/home/ubuntu/.jupyter/jupyter_notebook_config.py"
JUPYTER_SERVICE="/etc/systemd/system/jupyter.service"
JUPYTER_PASSWD=""

# For Jenkins docker
JENKINS_IMAGE="jenkins"
JENKINS_NAME="jenkins"
JENKINS_PORT="8080"
JENKINS_DIR="${WORK_DIR}/jenkins"
JENKINS_ADMIN="root"
