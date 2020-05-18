## Ubuntu WebServer
Practice Ubuntu Webserver on Amazon Lightsail Cloud
```
$ git clone https://github.com/mcodegeeks/ubuntu_webserver.git
$ cd ubuntu_webserver
$ ./setup.sh [OPTIONS]
```

## Setup Options
```
usage: ./setup.sh [OPTIONS]
options:
  -h,  --help              Print this help.
  -b,  --build             Build images before starting containers.
  -r,  --rmi               Remove all images used by any service.
  -o,  --os-specific       Setup os-specific dependencies.
       --openssl           Create a self-signed certificate.
       --jupyter           Insall Jupyter Notebook service.
       --time-zone         Set system time zone.
  -v,  --volumes           Remove named volumes declared in the 'volumes'
                           section of the Compose file and anonymous volumes
                           attached to containers.
```

For example:
```
# For production (Server)
$ ./setup.sh -o --jupyter --time-zone="America/Toronto"

# For development
$ ./setup.sh

# For docker image refresh
$ ./setup.sh --rmi

# For docker build instead of pull
$ ./setup.sh --build
```

## Services
* Web Application (GUnicorn) port: 5000
* Jupyter Notebook port: 8888
* Nginx Webserver port: 80
  
```
# Services Up
$ docker-compose up --no-build -d

# Services Down
$ docker-compose down
```

## Developing flask application
```
# Change working directory
$ cd ./app

# Create a virtual environment
$ python3 -m venv venv 

# Activate the virtual environment
$ source venv/bin/activate

# Installing required packages
(venv) pip install -r requirements.txt

# Run the flask app
(venv) $ flask run
```
```
http://localhost:5000
```

## Tip for SSH connection on Localmachine
- Generate SSH key pair or refresh known hostname and ip
```
$ ssh-keygen -t rsa -q -N ""
```
```
$ ssh-keygen -R <domain>
$ ssh-keygen -R <ip>
```
- Copy local SSH public key and paste it on the server instance 
```
$ cat ~/.ssh/id_rsa.pub | ssh -i <aws_generated_key>.pem ubuntu@<domain> 'tee -a ~/.ssh/authorized_keys'
```
- Now, you can simply login SSH with the following:
```
$ ssh ubuntu@<domain>
```
