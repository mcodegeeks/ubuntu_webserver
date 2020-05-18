# common
USER="ubuntu"

SSH_KEY="id_rsa"
SSH_DIR="/${USER}/.ssh"
SSH_CFG="/etc/ssh/sshd_config"
SSL_DIR="${SSH_CFG}"

TIME_ZONE="America/Toronto"




# Docker Images
DOCKER_UBUNTU="ubuntu:18.04"
DOCKER_JENKINS="jenkins/jenkins"


# For Jupyter
JUPYTER_CFG="/home/${USER}/.jupyter/jupyter_notebook_config.py"
JUPYTER_SERVICE="/etc/systemd/system/jupyter.service"
JUPYTER_PASSWD=""
JUPYTER_PY_TEMP="/tmp/temp.py"





# For Jenkins docker
JENKINS_IMAGE="jenkins/jenkins"
JENKINS_NAME="jenkins"
JENKINS_PORT="8080"
JENKINS_DIR="${WORK_DIR}/jenkins"
JENKINS_ADMIN="root"





# For Database
#POSTGRES_DATA_DIR="${WORK_DIR}/db/postgres"
