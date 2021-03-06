### Reference
https://docs.docker.com/engine/reference/commandline/docker/

### Frequent Usages
```
$ docker pull ubuntu:18.04
$ docker pull python:3
$ docker pull nginx
$ docker pull mysql:5.6
$ docker pull jenkins/jenkins
$ docker pull mcodegeeks/homepage

$ docker-compose pull
$ docker-compose up --no-build -d
$ docker-compose stop

$ docker run --name nginx -p 80:80 -v "$(pwd)/html":/usr/share/nginx/html:ro -d --rm nginx
$ docker run --name nginx -p 80:80 -v "$(pwd)/nginx/nginx.conf":/etc/nginx/conf.d/default.conf:ro -v volume-nginx:/data/nginx --rm nginx
$ docker exec -it nginx /bin/bash

$ docker run --name apache -p 8080:80 -v /var/www/html:/usr/local/apache2/htdocs/ -dit --rm httpd

$ docker run --name jenkins -p 8080:8080 -p 50000:50000 -v volume-jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock -u root -d jenkins/jenkins:custom
$ docker exec -it -u root jenkins /bin/bash
$ docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
$ docker logs jenkins

$ docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD='' -d --rm mysql:5.6
$ docker exec -it mysql mysql -u root -p
$ docker exec -it mysql /bin/bash
$ mysql -u root -p

$ docker run --name postgres -p 5432:5432 --env-file ./.env.db -v volume-postgres:/var/lib/postgresql/data -d --rm postgres
$ docker exec -it postgres psql --username='' --dbname=''
$ docker exec -it postgres /bin/bash

$ docker build -t mcodegeeks/homepage .
$ docker run --name homepage -p 5000:5000 -v volume-homepage:/data/app -v volume-nginx:/data/nginx -v volume-postgres:/data/postgres -d --rm mcodegeeks/homepage
$ docker run -it --rm mcodegeeks/homepage /bin/bash
$ docker exec -it homepage /bin/bash
```

### Commands
```
$ docker attach                                 # Attach local standard input, output, and error streams to a running container
$ docker build                                  # Build an image from a Dockerfile
$ docker builder                                # Manage builds
$ docker checkpoint                             # Manage checkpoints
$ docker commit                                 # Create a new image from a container’s changes
$ docker config                                 # Manage Docker configs
$ docker container                              # Manage containers
$ docker context                                # Manage contexts
$ docker cp                                     # Copy files/folders between a container and the local filesystem
$ docker create                                 # Create a new container
$ docker diff                                   # Inspect changes to files or directories on a container’s filesystem
$ docker events                                 # Get real time events from the server
$ docker exec                                   # Run a command in a running container
$ docker export                                 # Export a container’s filesystem as a tar archive
$ docker history                                # Show the history of an image
$ docker image                                  # Manage images
$ docker images                                 # List images
$ docker import                                 # Import the contents from a tarball to create a filesystem image
$ docker info                                   # Display system-wide information
$ docker inspect                                # Return low-level information on Docker objects
$ docker kill                                   # Kill one or more running containers
$ docker load                                   # Load an image from a tar archive or STDIN
$ docker login                                  # Log in to a Docker registry
$ docker logout                                 # Log out from a Docker registry
$ docker logs                                   # Fetch the logs of a container
$ docker manifest                               # Manage Docker image manifests and manifest lists
$ docker network                                # Manage networks
$ docker node                                   # Manage Swarm nodes
$ docker pause                                  # Pause all processes within one or more containers
$ docker plugin                                 # Manage plugins
$ docker port                                   # List port mappings or a specific mapping for the container
$ docker ps [OPTIONS]                           # List containers
    -a                                            Show all containers (default shows just running)
$ docker pull [OPTIONS] NAME[:TAG|@DIGEST]      # Pull an image or a repository from a registry
$ docker push                                   # Push an image or a repository to a registry
$ docker rename                                 # Rename a container
$ docker restart                                # Restart one or more containers
$ docker rm [OPTIONS] CONTAINER [CONTAINER...]  # Remove one or more containers
    --force , -f                                  Force the removal of a running container (uses SIGKILL)
$ docker rmi                                    # Remove one or more images
$ docker run [OPTIONS]                          # Run a command in a new container
  --detach , -d                                   Run container in background and print container ID
  --env , -e                                      Set environment variables
  --interactive , -i                              Keep STDIN open even if not attached
  --name                                          Assign a name to the container
  --publish, -p                                   Publish a container’s port(s) to the host
  --rm                                            Automatically remove the container when it exits
  --tty , -t                                      Allocate a pseudo-TTY  
  --volume , -v                                   Bind mount a volume
$ docker save                                   # Save one or more images to a tar archive (streamed to STDOUT by default)
$ docker search                                 # Search the Docker Hub for images
$ docker secret                                 # Manage Docker secrets
$ docker service                                # Manage services
$ docker stack                                  # Manage Docker stacks
$ docker start                                  # Start one or more stopped containers
$ docker stats                                  # Display a live stream of container(s) resource usage statistics
$ docker stop                                   # Stop one or more running containers
$ docker swarm                                  # Manage Swarm
$ docker system                                 # Manage Docker
$ docker tag                                    # Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
$ docker top                                    # Display the running processes of a container
$ docker trust                                  # Manage trust on Docker images
$ docker unpause                                # Unpause all processes within one or more containers
$ docker update                                 # Update configuration of one or more containers
$ docker version                                # Show the Docker version information
$ docker volume                                 # Manage volumes
$ docker wait                                   # Block until one or more containers stop, then print their exit codes
```