#!/bin/bash
source setup_config.sh

echo "Pulling jenkins docker image..."
docker pull $JENKINS_IMAGE
echo -e "Done!\n"

echo "Adding jenkins working directory (${JENKINS_DIR})..."
mkdir -p $JENKINS_DIR
echo -e "Done!\n"

line=$(docker ps -a | grep $JENKINS_NAME)
if [[ ! -z $line ]]; then
    echo "Removing jenkins docker container..."
    docker rm -f $JENKINS_NAME
    echo -e "Done!\n"
fi

echo "Runing jenkins docker container..."
docker run --name $JENKINS_NAME -p $JENKINS_PORT:8080 -v $JENKINS_DIR:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -u $JENKINS_ADMIN -d jenkins
echo -e "Done!\n"

echo "An admin user has been created and a password generated."
echo "Please use the following password to proceed to installation:"
docker exec $JENKINS_NAME cat /var/jenkins_home/secrets/initialAdminPassword
