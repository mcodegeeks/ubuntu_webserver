## Ubuntu WebServer
Practice Ubuntu Webserver on Amazon Lightsail Cloud
```
$ git clone https://github.com/mcodegeeks/ubuntu_webserver.git
```

## Essential Setup for Ubuntu
- Updating SSH config for keeping client connection
- Generate SSH key pair
- Updating time zone (America/Toronto)
- Enabling swap file
- Updating software repositories
- Installing docker-ce and docker-compose
- Adding web working directory and group (ubuntu:www /var/www)
```
$ sudo ./setup_ubuntu.sh 
$ exit
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

## Install Jupyter (Optional)
```
$ sudo ./setup_jupyter.sh <password>
```
```
https://<domain>:8888
```

## Install Jenkins (Optional)
```
$ ./setup_jenkins.sh
```
- After installation completes, you can find the following message:
```
$ ./setup_jenkins.sh 
...

Waiting for an initial admin password to be generated...
Please use the following password to proceed to installation:
e5a40bfb670943b8829673315d7099ed

```
```
https://<domain>:8080
```

## Install Appliction 
```
$ docker run -it --rm --name hompage mcodegeeks/homepage  
```
