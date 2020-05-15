#!/bin/bash
source setup_config.sh

echo "Pulling jenkins docker image..."
docker pull jenkins
echo "Done!"

echo ""

echo "Adding jenkins working directory (${JENKINS_DIR})..."
mkdir -p ${JENKINS_DIR}
echo "Done!"

echo ""

echo "Executing jenkins docker container..."
docker rm -f jenkins
docker run --name jenkins -p $JENKINS_PORT:8080 -v $JENKINS_DIR:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -u $JENKINS_ADMIN -d jenkins
echo "Done!"

echo "An admin user has been created and a password generated."
echo "Please use the following password to proceed to installation:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
