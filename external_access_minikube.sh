#! /bin/bash

___console_logs () {
    printf "\n>>>>>>>>> $1\n"
    sleep 1
}

pm=$(./_identify_package_manager.sh)

___console_logs "Package Manager: $pm"

NGINX_EXTERNAL_PORT=80
NGINX_CONTAINER_NAME=nginx-minikube
NGINX_USER=minikube
NGINX_PASS=toor

___console_logs 'Creating folders: /etc/nginx/conf.d/ /etc/nginx/certs'
mkdir -p /etc/nginx/conf.d/ /etc/nginx/certs

___console_logs 'Creating NGINX configuration file in /etc/nginx/conf.d'
cat <<EOF > /etc/nginx/conf.d/minikube.conf 
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;
    auth_basic "Administrator’s Area";
    auth_basic_user_file /etc/nginx/.htpasswd;    
    
    location / {   
        proxy_pass https://`minikube ip`:8443;
        proxy_ssl_certificate /etc/nginx/certs/minikube-client.crt;
        proxy_ssl_certificate_key /etc/nginx/certs/minikube-client.key;
    }
}
EOF

___console_logs 'Creating user/password to NGINX with htpasswd'
$pm install -y httpd-tools
sleep 2
htpasswd -b -c /etc/nginx/.htpasswd $NGINX_USER $NGINX_PASS

___console_logs 'Delete if exist Nginx Container'
docker rm -f $NGINX_CONTAINER_NAME
# sleep 2

___console_logs 'Docker Create and Run Nginx Container'
docker run -d --name $NGINX_CONTAINER_NAME -p $NGINX_EXTERNAL_PORT:80 -v /root/.minikube/profiles/minikube/client.key:/etc/nginx/certs/minikube-client.key -v /root/.minikube/profiles/minikube/client.crt:/etc/nginx/certs/minikube-client.crt -v /etc/nginx/conf.d/:/etc/nginx/conf.d -v /etc/nginx/.htpasswd:/etc/nginx/.htpasswd nginx

# sleep 2
___console_logs 'Docker Nginx Container Show'
docker ps -a | grep $NGINX_CONTAINER_NAME