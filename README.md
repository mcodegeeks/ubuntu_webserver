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
```
$ sudo ubuntu_webserver/setup_ubuntu.sh 
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
$ sudo ubuntu_webserver/setup_jupyter.sh <password>
```
```
https://<domain>:88888
```
