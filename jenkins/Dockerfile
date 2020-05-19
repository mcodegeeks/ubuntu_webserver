FROM jenkins/jenkins

# USE root privilege
USER root

# Updating software repositories
RUN apt-get update

# Installing prerequisite packages
RUN apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common

# Adding GPG key for the official docker repository
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -

# Installing from the docker repo
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"

# Updating the package database with the docker packages
RUN apt update

# Installing docker ce
RUN apt -y install docker-ce

# Installing docker compose
RUN apt -y install docker-compose

# Adding jenkins user in the docker group
RUN usermod -a -G docker jenkins

# Return to jenkins user
USER jenkins
