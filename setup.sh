#!/bin/bash

DATA_VOLUME="data-volume"
IMAGE_HOMEPAGE="mcodegeeks/homepage"
CONTAINER_HOMEPAGE="homepage"

function show_help() {
    echo "usage: $0 [OPTIONS]"
    echo "options:"
    echo "  -h,  --help              Print this help."
    echo "  -b,  --build             Build images before starting containers."
    echo "  -r,  --rmi               Remove all images used by any service."
    echo "  -v,  --volumes           Remove named volumes declared in the 'volumes'"
    echo "                           section of the Compose file and anonymous volumes"
    echo "                           attached to containers."
}

build=no
rmi=no
volumes=no
optspec=":bhrv-:"
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
