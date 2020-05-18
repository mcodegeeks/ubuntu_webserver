#!/bin/bash
OS_NAME="Unknown"
SWAP_FILE="/var/swapfile"
DATA_VOLUME="data-volume"
IMAGE_HOMEPAGE="mcodegeeks/homepage"
CONTAINER_HOMEPAGE="homepage"

function show_help() {
    echo "usage: $0 [OPTIONS]"
    echo "options:"
    echo "  -h,  --help              Print this help."
    echo "  -b,  --build             Build images before starting containers."
    echo "  -r,  --rmi               Remove all images used by any service."
    echo "  -o,  --os-specific       Setup os-specific dependencies."
    echo "       --time-zone         Set system time zone."
    echo "  -v,  --volumes           Remove named volumes declared in the 'volumes'"
    echo "                           section of the Compose file and anonymous volumes"
    echo "                           attached to containers."
}

build=no
rmi=no
os_specific=no
time_zone="America/Toronto" # "UTC"
volumes=no
optspec=":bhorv-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                build)
                    build=yes;;
                rmi)
                    rmi=yes;;
                volumes)
                    volumes=yes;;
                os-specific)
                    # val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    os_specific=yes;;
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
            exit 2;;
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

    line=$(grep ".*${key}[[:space:]]*${delim}" $file)
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

function ssh_config_update() {
    local file="/etc/ssh/sshd_config"
    echo "Updating SSH config '${file}'..."
    config_update $file 'ClientAliveInterval' 60 ' ' yes
    sudo service sshd restart
    echo -e "Done!\n"
}

function ssh_key_generate() {
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

function set_system_time_zone_for_ubuntu() {
    echo "Set system time zone..."
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
    sudo apt -y install apt-transport-https ca-certificates curl software-properties-common python3-venv
    echo -e "Done!\n"

    echo "Adding GPG key for the official docker repository..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo ""

    echo "Update the package database with the docker packages..."
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

function docker_package_exist() {
    rc=$(which docker)
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
    local rc=$(docker volume ls | grep "$DATA_VOLUME")
    if [[ -z $rc ]]; then
        return 0
    fi
    return 1
}

function docker_remove_volume() {
    docker_volume_exist
    if [[ $? -eq 1 ]]; then
        echo "Removing data volume..."
        docker volume rm -f $DATA_VOLUME
        echo -e "Done!\n"
    fi
}

function docker_create_volume() {
    docker_volume_exist
    if [[ $? -eq 0 ]]; then
        echo "Creating data volume..."
        docker volume create $DATA_VOLUME
        echo -e "Done!\n"
    fi
}

function docker_pull_images() {
    echo "Pulling images for services defined in the docker-compose.yml..."
    docker-compose pull
    echo -e "Done!\n"
}

function docker_remove_untaggeds() {
    local rc=$(docker images | grep "<none>" | awk '{print $3}')
    if [[ ! -z $rc ]]; then
        echo "Removing untagged images..."
        docker rmi -f $rc
        echo -e "Done!\n"        
    fi
}

function docker_remove_images() {
    echo "Removing images..."
    docker rmi -f $(docker images | grep "${IMAGE_HOMEPAGE}" | awk '{print $3}')
    echo -e "Done!\n"
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
    if [[ $build = yes ]]; then 
        docker_remove_images
        docker_build_images
    fi
    echo "Starting services..." 
    docker-compose up --no-build -d
    echo -e "Done!\n"
}

function os_specific_for_ubuntu() {
    ssh_config_update
    ssh_key_generate
    set_system_time_zone_for_ubuntu
    create_virtual_memory
    install_packages_for_ubuntu
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
docker_remove_untaggeds
if [[ $volumes = yes ]]; then
    docker_remove_volume
fi
docker_create_volume
docker_start_services
