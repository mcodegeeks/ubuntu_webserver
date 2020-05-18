#!/bin/bash
OS_NAME="Unknown"
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
    echo "  -v,  --volumes           Remove named volumes declared in the 'volumes'"
    echo "                           section of the Compose file and anonymous volumes"
    echo "                           attached to containers."
}

build=no
rmi=no
os_specific=no
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
                    os_specific=yes;;
                #loglevel)
                #    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                #    echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2;
                #    ;;
                #loglevel=*)
                #    val=${OPTARG#*=}
                #    opt=${OPTARG%=$val}
                #    echo "Parsing option: '--${opt}', value: '${val}'" >&2
                #    ;;
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

function get_os_version() {
    local file="/etc/os-release"
    if [[ -f $file ]]; then
        OS_NAME=$(grep "^NAME=" $file | sed "s|^NAME=||g" | cut -d '"' -f2)
    fi

    if [[ $OS_NAME = "Ubuntu" ]]; then
        echo $OS_NAME
    else
        echo "Only Ubuntu OS can be supported!"
    fi

    if [[ $os_specific = "yes" ]]; then
        exit 0
    fi
}

function config_append() {
    local file=$1
    local val=$2

    if [[ ! -f $file ]]; then
        touch $file
    fi

    echo "(+) ${val}"
    echo "${val}" | tee -a $file > /dev/null
}
 
function config_update() {
    local file=$1
    local key=$2
    local val=$3
    local delim=$4
    local line=""

    if [[ ! -f $1 ]]; then
        touch $1
    fi

    line=$(grep ".*${key}[[:space:]]*${delim}" $file)
    if [[ -z $line ]]; then
        echo "(+) ${key}${delim}${val}"
        echo "${key}${delim}${val}" | tee -a $file > /dev/null
    else
        echo "(-) $line"
        echo "(+) ${key}${delim}${val}"
        sed -ie "s|.*${key}[[:space:]]*${delim}.*|${key}${delim}${val}|" $file
    fi
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

get_os_version

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
