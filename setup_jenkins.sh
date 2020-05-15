#!/bin/bash
source setup_config.sh

echo "Pulling jenkins docker image..."
docker pull $JENKINS_IMAGE
echo -e "Done!\n"

echo "Adding jenkins working directory (${JENKINS_DIR})..."
sudo rm -rf $JENKINS_DIR
mkdir -p $JENKINS_DIR
echo -e "Done!\n"

line=$(docker ps -a | grep $JENKINS_NAME)
if [[ ! -z $line ]]; then
    echo "Removing jenkins docker container..."
    docker rm -f $JENKINS_NAME
    echo -e "Done!\n"
fi

echo "Runing jenkins docker container..."
docker run --name $JENKINS_NAME -p $JENKINS_PORT:8080 -p 50000:50000 -v $JENKINS_DIR:/var/jenkins_home -v $DOCKER_SOCK:$DOCKER_SOCK -v $DOCKER_BIN:$DOCKER_BIN -u root -d $JENKINS_IMAGE
echo -e "Done!\n"

echo "Waiting for an initial admin password to be generated..."
n=0
while [ $n -le 10 ]
do
    if sudo test -f "${JENKINS_DIR}/secrets/initialAdminPassword"; then
        echo "Please use the following password to proceed to installation:"
        sudo cat "${JENKINS_DIR}/secrets/initialAdminPassword"
        echo "Done!"
        exit 0
    else
        sleep 3
        (( n++ ))
    fi
done
echo "The password isn't generated at this moment. Find '${JENKINS_DIR}/secrets/initialAdminPassword' later."
echo "Done!"
