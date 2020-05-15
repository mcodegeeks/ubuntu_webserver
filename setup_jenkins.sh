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
docker run --name $JENKINS_NAME -p $JENKINS_PORT:8080 -p 50000:50000 -v $JENKINS_DIR:/var/jenkins_home -v $DOCKER_SOCK:$DOCKER_SOCK -v $DOCKER_BIN:$DOCKER_BIN -d $JENKINS_IMAGE
echo -e "Done!\n"

echo "Waiting for an initial admin password to be generated..."
while [ ! -f "${JENKINS_DIR}/secrets/initialAdminPassword" ]
do
    sleep 2
done
echo "Please use the following password to proceed to installation:"
cat "${JENKINS_DIR}/secrets/initialAdminPassword"
echo "Done!"
