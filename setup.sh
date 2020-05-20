#!/bin/bash
OS_NAME="Unknown"
SWAP_FILE="/var/swapfile"
JUPYTER_PASSWD=""
VOLUME_HOMEPAGE="volume-homepage"
VOLUME_NGINX="volume-nginx"
VOLUME_POSTGRES="volume-postgres"
VOLUME_JENKINS="volume-jenkins"
IMAGE_HOMEPAGE="mcodegeeks/homepage"
IMAGE_JENKINS="jenkins/jenkins"
CONTAINER_HOMEPAGE="homepage"
function show_help() {
    echo "usage: $0 [OPTIONS]"
    echo "options:"
    echo "  -h,  --help              Print this help."
    echo "  -b,  --build             Build images before starting containers."
    echo "  -r,  --rmi               Remove all images used by any service."
    echo "  -o,  --os-specific       Setup os-specific dependencies."
    echo "       --openssl           Create a self-signed certificate."
    echo "       --jenkins           Install Jenkins service."
    echo "       --jupyter           Install Jupyter Notebook service."
    echo "       --time-zone         Set system time zone."
    echo "  -v,  --volumes           Remove named volumes declared in the 'volumes'"
    echo "                           section of the Compose file and anonymous volumes"
    echo "                           attached to containers."
}

build=no
rmi=no
os_specific=no
openssl=no
jenkins=no
jupyter=no
time_zone="America/Toronto" # "UTC"
volumes=no
optspec=":bhorv-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                help)
                    show_help
                    exit 2
                    ;;
                build)
                    build=yes;;
                rmi)
                    rmi=yes;;
                volumes)
                    volumes=yes;;
                os-specific)
                    os_specific=yes;;
                openssl)
                    openssl=yes;;
                jenkins)
                    jenkins=yes;;
                jupyter)
                    jupyter=yes;;
                jupyter=*)
                    val=${OPTARG#*=}
                    opt=${OPTARG%=$val}
                    JUPYTER_PASSWD=$val
                    jupyter=yes;;
                time-zone=*)
                    val=${OPTARG#*=}
                    opt=${OPTARG%=$val}
                    time_zone=$val
                    ;;
                *)
                    echo "invalid option --${OPTARG}" >&2
                    show_help
                    exit 2
                    ;;
            esac;;
        h)
            show_help
            exit 2
            ;;
        b)
            build=yes;;
        o)
            os_specific=yes;;
        r)
            rmi=yes;;
        v)
            volumes=yes;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "invalid option: '-${OPTARG}'" >&2
                show_help
                exit 2
            fi
            ;;
    esac
done

function config_append() {
    local file=$1
    local val=$2
    local sudo=""

    if [[ ! -z $3 || $3 = 'yes' ]]; then
        sudo="sudo"
    fi

    if [[ ! -f $file ]]; then
        $sudo touch $file
    fi

    echo "(+) ${val}"
    echo "${val}" | $sudo tee -a $file > /dev/null
}
 
function config_update() {
    local file=$1
    local key=$2
    local val=$3
    local delim=$4
    local sudo=""
    local line=""

    if [[ ! -z $5 || $5 = 'yes' ]]; then
        sudo="sudo"
    fi

    if [[ ! -f $1 ]]; then
        $sudo touch $1
    fi

    line=$($sudo grep ".*${key}[[:space:]]*${delim}" $file)
    if [[ -z $line ]]; then
        echo "(+) ${key}${delim}${val}"
        echo "${key}${delim}${val}" | $sudo tee -a $file > /dev/null
    else
        echo "(-) $line"
        echo "(+) ${key}${delim}${val}"
        $sudo sed -ie "s|.*${key}[[:space:]]*${delim}.*|${key}${delim}${val}|" $file
    fi
}

function get_os_version() {
    local file="/etc/os-release"
    if [[ -f $file ]]; then
        OS_NAME=$(grep "^NAME=" $file | sed "s|^NAME=||g" | cut -d '"' -f2)
    fi
}

function update_ssh_config() {
    local file="/etc/ssh/sshd_config"
    echo "Updating SSH config '${file}'..."
    config_update $file 'ClientAliveInterval' 60 ' ' yes
    sudo service sshd restart
    echo -e "Done!\n"
}

function create_ssh_key() {
    local dir="${HOME}/.ssh"
    local file="${dir}/id_rsa"
    mkdir -p $dir

    if [ -f $file ]; then
        echo -e "SSH key pair '${file}' already exists.\n"
    else
        echo "Generating SSH key pair '${file}'..."
        ssh-keygen -t rsa -f $file -q -N ""
        echo -e "Done!\n"
    fi

    cat "${file}.pub"
    echo ""
}

function create_ssl_cert() {
    local dir="${HOME}/.ssh"
    local key="${dir}/cert.key"
    local cert="${dir}/cert.pem"

    echo "Creating SSL certificate and key..."
    openssl rand -out /home/ubuntu/.rnd -hex 256
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $key -out $cert -batch
    echo -e "Done!\n"
}

function set_system_time_zone_for_ubuntu() {
    echo "Settting system time zone..."
    timedatectl set-ntp yes
    sudo timedatectl set-timezone $time_zone
    timedatectl
    echo -e "Done!\n"
}

function create_virtual_memory() {
    echo "Creating virtual memory file '${SWAP_FILE}'..."
    if [ -f $SWAP_FILE ]; then
        echo "The file already exists."
    else
        sudo dd if=/dev/zero of=$SWAP_FILE bs=1M count=4096
        sudo chmod 600 $SWAP_FILE
        sudo mkswap $SWAP_FILE
        sudo swapon $SWAP_FILE
        echo "${SWAP_FILE}   swap    swap    defaults        0   0" | sudo tee -a /etc/fstab > /dev/null
        sudo swapon -a
        sudo swapon --show
    fi
    echo -e "Done!\n"
}

function install_packages_for_ubuntu() {
    echo "Updating software repositories..."
    sudo apt -y update
    echo -e "Done!\n"

    echo "Installing prerequisite packages..."
    sudo apt -y install apt-transport-https ca-certificates curl software-properties-common python3-pip python3-venv
    echo -e "Done!\n"

    echo "Adding GPG key for the official docker repository..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo ""

    echo "Updating the package database with the docker packages..."
    sudo apt -y update
    echo -e "Done!\n"

    echo "Installing from the docker repo instead of the default Ubuntu repo..."
    sudo apt-cache policy docker-ce
    echo -e "Done!\n"

    echo "Installing docker ce..."
    sudo apt -y install docker-ce
    echo -e "Done!\n"

    echo "Installing docker compose..."
    sudo apt -y install docker-compose
    echo -e "Done!\n"

    echo "Adding ${USER} user in the docker group..." 
    sudo usermod -aG docker $USER
    echo -e "Done!\n"
}

function install_jupyter_service() {
    local file="${HOME}/.jupyter/jupyter_notebook_config.py"
    local service="/etc/systemd/system/jupyter.service"
    local ipaddr=$(hostname -I | awk '{print $1}')
    local sha1=""

    echo "Installing Jupyter Notebook service..."
    sudo pip3 install notebook
    echo -e "Done!\n"

    echo "Generating SHA1 hash value..."
    sha1=$(python3 ./jupyter/gen_sha1.py $JUPYTER_PASSWD)
    echo $sha1
    echo -e "Done!\n"

    echo "Generating Jupyter Notebook config ..."
    sudo jupyter notebook --generate -y
    config_update $file "c.NotebookApp.password" "u'${sha1}'" ' = ' yes
    config_update $file "c.NotebookApp.ip" "'${ipaddr}'" ' = ' yes
    config_update $file "c.NotebookApp.notebook_dir" "'/'" ' = ' yes
    if [[ $openssl = "yes" ]]; then
        local dir="${HOME}/.ssh"
        local key="${dir}/cert.key"
        local cert="${dir}/cert.pem"
        config_update $file "c.NotebookApp.certfile" "u'${cert}'" ' = ' yes
        config_update $file "c.NotebookApp.keyfile" "u'${key}'" ' = ' yes
    fi
    echo -e "Done!\n"

    echo "Adding Jupyter as System Service '${service}'..."
    sudo cp ./jupyter/jupyter.service $service
    sudo systemctl daemon-reload
    sudo systemctl enable jupyter
    sudo systemctl restart jupyter
    echo -e "Done!\n"
}

function docker_package_exist() {
    local rc=$(which docker)
    if [[ -z $rc ]]; then
        echo "Please, install 'docker' package first..."
        exit 2
    fi

    rc=$(which docker-compose)
    if [[ -z $rc ]]; then
        echo "Please, install 'docker-compose' package first..."
        exit 2
    fi
}

function docker_volume_exist() {
    local rc=$(docker volume ls | grep "$1")
    if [[ -z $rc ]]; then
        return 0
    fi
    return 1
}

function docker_remove_volumes() {
    docker_volume_exist $VOLUME_HOMEPAGE
    if [[ $? -eq 1 ]]; then
        echo "Removing homepage data volume..."
        docker volume rm -f $VOLUME_HOMEPAGE
        echo -e "Done!\n"
    fi
    docker_volume_exist $VOLUME_NGINX
    if [[ $? -eq 1 ]]; then
        echo "Removing nginx data volume..."
        docker volume rm -f $VOLUME_NGINX
        echo -e "Done!\n"
    fi
    docker_volume_exist $VOLUME_POSTGRES
    if [[ $? -eq 1 ]]; then
        echo "Removing postgres data volume..."
        docker volume rm -f $VOLUME_POSTGRES
        echo -e "Done!\n"
    fi
    if [[ $jenkins = "yes" ]]; then
        docker_volume_exist $VOLUME_JENKINS
        if [[ $? -eq 1 ]]; then
            echo "Removing jenkins data volume..."
            docker volume rm -f $VOLUME_JENKINS
            echo -e "Done!\n"
        fi
    fi
}

function docker_create_volumes() {
    docker_volume_exist $VOLUME_HOMEPAGE
    if [[ $? -eq 0 ]]; then
        echo "Creating homepage data volume..."
        docker volume create $VOLUME_HOMEPAGE
        echo -e "Done!\n"
    fi
    docker_volume_exist $VOLUME_NGINX
    if [[ $? -eq 0 ]]; then
        echo "Creating nginx data volume..."
        docker volume create $VOLUME_NGINX
        echo -e "Done!\n"
    fi
    docker_volume_exist $VOLUME_POSTGRES
    if [[ $? -eq 0 ]]; then
        echo "Creating postgres data volume..."
        docker volume create $VOLUME_POSTGRES
        echo -e "Done!\n"
    fi
    if [[ $jenkins = "yes" ]]; then
        docker_volume_exist $VOLUME_JENKINS
        if [[ $? -eq 0 ]]; then
            echo "Creating jenkins data volume..."
            docker volume create $VOLUME_JENKINS
            echo -e "Done!\n"
        fi
    fi
}

function docker_pull_images() {
    echo "Pulling images for services defined in the docker-compose.yml..."
    docker-compose pull
    echo -e "Done!\n"
}

function docker_prune_unused() {
    echo "Removing unused containers, networks, images and volumes..."
    docker system prune -f
    docker volume prune -f
    echo -e "Done!\n"
}

function docker_remove_images() {
    local rc=""
    echo "Removing images..."
    rc=$(docker images | grep "${IMAGE_HOMEPAGE}" | awk '{print $3}')
    if [[ ! -z $rc ]]; then
        docker rmi -f $rc
    fi
    if [[ $jenkins = "yes" ]]; then
        rc=$(docker images | grep "${IMAGE_JENKINS}" | grep custom | awk '{print $3}')
        if [[ ! -z $rc ]]; then
            docker rmi -f $rc
        fi
    fi
    echo -e "Done!\n"
}

function docker_build_jenkins() {
    local rc=$(docker images | grep "${IMAGE_JENKINS}" | grep custom | awk '{print $3}')
    if [[ -z $rc ]]; then
        echo "Building jenkins image..."
        docker build -t $IMAGE_JENKINS:custom ./jenkins
        echo -e "Done!\n"
    fi
}

function docker_build_images() {
    echo "Building images..."
    docker build -t $IMAGE_HOMEPAGE .
    echo -e "Done!\n"
}

function docker_stop_services() {
    local rc=""
    echo "Stopping services..."
    docker-compose down
    rc=$(docker ps -a | grep "${CONTAINER_HOMEPAGE}")
    if [[ ! -z $rc ]]; then
        docker rm -f $CONTAINER_HOMEPAGE
    fi
    echo -e "Done!\n"
}

function docker_start_services() {
    local rc=""
    if [[ $build = yes ]]; then 
        docker_remove_images
        docker_build_images
    fi
    if [[ $jenkins = "yes" ]]; then
        docker_build_jenkins
    fi
    echo "Starting services..." 
    docker-compose up --no-build -d
    rc=$(docker images | grep "${IMAGE_JENKINS}" | grep custom)
    if [[ ! -z $rc ]]; then
        rc=$(docker ps | grep jenkins)
        if [[ -z $rc ]]; then
            echo "Creating jenkins  ... done"
            docker run --name jenkins -p 8080:8080 -p 50000:50000 -v volume-jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -u root -d $IMAGE_JENKINS:custom 
        fi
    fi
    echo -e "Done!\n"
}

function os_specific_for_ubuntu() {
    update_ssh_config
    create_ssh_key
    if [[ $openssl = "yes" ]]; then
        create_ssl_cert
    fi    
    set_system_time_zone_for_ubuntu
    create_virtual_memory
    install_packages_for_ubuntu
    if [[ $jupyter = "yes" ]]; then
        install_jupyter_service
    fi
}

get_os_version
if [[ $os_specific = "yes" ]]; then
    if [[ $OS_NAME = "Ubuntu" ]]; then
        os_specific_for_ubuntu
    else
        echo -e "Only Ubuntu OS can be supported!\n"
    fi
fi
docker_package_exist
docker_stop_services
if [[ $rmi = "yes" ]]; then
    docker_remove_images
fi
docker_pull_images
if [[ $volumes = yes ]]; then
    docker_remove_volumes
fi
docker_create_volumes
docker_start_services
docker_prune_unused
