SUDO_PASS=$1
SO_USER=$(echo ${USER})
SO_USER_GROUP=docker
IP=$(hostname -I |  awk '{print $1}')
MINIKUBE_INSTALL_ROOT_FOLDER=$HOME/minikube-install
MINIKUBE_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/minikube
NGINX_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/nginx

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 1
}

# echo '##########################################################################'
# echo '############################ INSTALL MINIKUBE ############################'
# echo '##########################################################################\n'

# ___console_logs '[--] Check if the sudo password was entered'
# if [ -z "${SUDO_PASS}" ]; then
#     echo "XXX sudo password not entered!! XXX"
#     echo "Sample: install-minikube__ubuntu.sh <sudo pass>"
#     exit 1
# else
#     echo "==> sudo password entered."
# fi

# ___console_logs '[01/20] Install a few prerequisite packages'
# echo $SUDO_PASS | sudo -S apt install -yqqq tree yq

# ___console_logs '[02/20] Verify Docker installed'
# IS_DOCKER=$(which docker)
# if [ -z "${IS_DOCKER}" ]; then
#     echo "XXX Docker NOT installed. Docker is a basic requirement for minikube!! XXX"
#     exit 1
# else
#     echo "==> Docker INSTALLED."
# fi

# ___console_logs '[03/20] Download Minikube'
# curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64

# ___console_logs '[04/20] Install Minikube'
# echo $SUDO_PASS | sudo -S install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
# which minikube

# ___console_logs '[05/20] Download Kubectl'
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
# echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# ___console_logs '[06/20] Install Kubectl'
# echo $SUDO_PASS | sudo -S install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl && rm kubectl.sha256
# kubectl version --client --output=yaml

# ___console_logs '[07/20] Config Docker default driver'
# minikube config set driver docker

# ___console_logs '[08/20] Minikube Start'
# minikube start --force

# ___console_logs '[09/20] Minikube Status'
# minikube status

# ___console_logs '[10/20] Configure Kickoff Minikube Cluster on Machine Startup'
# sudo -i -u root bash << EOF
# echo $SUDO_PASS | sudo -S cat <<EOF2 > /etc/systemd/system/minikube.service
# [Unit]
# Description=Kickoff Minikube Cluster
# After=docker.service

# [Service]
# Type=oneshot
# ExecStart=/usr/local/bin/minikube start --force
# RemainAfterExit=true
# ExecStop=/usr/local/bin/minikube stop
# StandardOutput=journal
# User=$SO_USER
# Group=$SO_USER_GROUP

# [Install]
# WantedBy=multi-user.target
# EOF2
# EOF
# echo "========================= [minikube.service] ========================="
# echo $SUDO_PASS | sudo -S cat /etc/systemd/system/minikube.service
# echo "====================================================================== [/etc/systemd/system/minikube.service]"

# ___console_logs '[11/20] Enable Minikube Service'
# echo $SUDO_PASS | sudo -S systemctl enable minikube
# systemctl status minikube

# echo '\n--------------------------------------------------------------------------'
# echo '--------------------------- CREATE NGINX PROXY ---------------------------'
# echo '--------------------------------------------------------------------------'

# ___console_logs '[12/20] Copy the certificate and key'
# mkdir -p $MINIKUBE_FOLDER
# mkdir -p $NGINX_FOLDER
# cp -rv $HOME/.minikube/profiles/minikube/client.crt $MINIKUBE_FOLDER
# cp -rv $HOME/.minikube/profiles/minikube/client.key $MINIKUBE_FOLDER
# cp -rv $HOME/.minikube/ca.crt $MINIKUBE_FOLDER

# ___console_logs '[13/20] Create NGINX password'
# echo $SUDO_PASS | sudo -S apt install -yqqq apache2-utils
# echo $SUDO_PASS | htpasswd -c -b -i $NGINX_FOLDER/.htpasswd $SO_USER

___console_logs '[14/20] Create nginx.conf file'
# cat <<EOF > $NGINX_FOLDER/nginx.conf
# events {
#     worker_connections 1024;
# }
# http {
#   server_tokens off;
#   auth_basic "Administrator’s Area";
#   auth_basic_user_file /etc/nginx/.htpasswd;
#   server {
#     listen 443;
#     server_name minikube;
#     location / {
#       proxy_set_header X-Forwarded-For \$remote_addr;
#       proxy_set_header Host            \$http_host;
#       proxy_pass https://minikube:8443;
#       proxy_ssl_certificate /etc/nginx/certs/minikube-client.crt;
#       proxy_ssl_certificate_key /etc/nginx/certs/minikube-client.key;
#     }
#   }
# }
# EOF



cat <<EOF > $NGINX_FOLDER/default.conf
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    # location / {
    #     root   /usr/share/nginx/html;
    #     index  index.html index.htm;
    # }
    location / {
        proxy_set_header Host "localhost";
        proxy_pass http://127.0.0.1:3030;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
EOF




echo "============================ [nginx.conf] ============================"
cat $NGINX_FOLDER/nginx.conf
echo "====================================================================== [$NGINX_FOLDER/nginx.conf]"

___console_logs '[15/20] Create Dockerfile'
# cat <<EOF > $NGINX_FOLDER/Dockerfile
# # Official Nginx image
# FROM nginx:latest

# # Copy Nginx configuration file to the container
# COPY nginx/nginx.conf /etc/nginx/nginx.conf

# # Copy minikube certs and password
# COPY  minikube/client.key /etc/nginx/certs/minikube-client.key
# COPY  minikube/client.crt /etc/nginx/certs/minikube-client.crt
# COPY nginx/.htpasswd /etc/nginx/.htpasswd

# # Expose port 80 and 443
# EXPOSE 80
# EXPOSE 443
# EOF




cat <<EOF > $NGINX_FOLDER/Dockerfile
# Official Nginx image
FROM nginx:latest

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Expose port 80 and 443
EXPOSE 80
EXPOSE 443
EOF




echo "============================ [Dockerfile] ============================"
cat $NGINX_FOLDER/Dockerfile
echo "====================================================================== [$NGINX_FOLDER/Dockerfile]"

___console_logs '[16/20] Build NGINX docker image'
docker build -t nginx-minikube-proxy -f $NGINX_FOLDER/Dockerfile $MINIKUBE_INSTALL_ROOT_FOLDER

___console_logs '[17/20] Run NGINX docker image'
OLD_CONTAINER_DELETED=$(docker rm --force nginx-minikube-proxy)
CONTAINER_ID=$(docker run -d --memory="500m" --memory-reservation="256m" --cpus="0.25" --restart=always --name nginx-minikube-proxy -p 443:443 -p 80:80 --network=minikube nginx-minikube-proxy)
echo "=====> OLD CONTAINER DELETED: [$OLD_CONTAINER_DELETED] <====="
echo "=====> CONTAINER ID: [$CONTAINER_ID] <====="
echo "=====> Container NGINX logs: <====="
docker logs $CONTAINER_ID

# ___console_logs '[18/20] Configure Kubeconfig to external access'
# cp -rv $HOME/.kube/config $MINIKUBE_FOLDER/kubeconfig
# yq -yi ".clusters[0].cluster.server = \"$SO_USER:$SUDO_PASS@$IP:443\"" $MINIKUBE_FOLDER/kubeconfig 
# yq -yi '.clusters[0].cluster."certificate-authority" = "ca.crt"' $MINIKUBE_FOLDER/kubeconfig
# yq -yi '.users[0].user."client-certificate" = "client.crt"' $MINIKUBE_FOLDER/kubeconfig
# yq -yi '.users[0].user."client-key" = "client.key"' $MINIKUBE_FOLDER/kubeconfig
# echo "============================ [kubeconfig] ============================"
# cat $MINIKUBE_FOLDER/kubeconfig
# echo "====================================================================== [$MINIKUBE_FOLDER/kubeconfig]"
# echo "=====> See the Kubeconfig for external access to minikube at: $MINIKUBE_FOLDER/Kubeconfig <====="

# ___console_logs '[19/20] Show all Configuration Files'
# tree -a $MINIKUBE_INSTALL_ROOT_FOLDER

# ___console_logs '[20/20] Informations'
# echo "=====> Copiar os arquivos de conexão externa gerados pela instalação do minikube: \`sshpass -p '$SUDO_PASS' scp -o StrictHostKeyChecking=no -r $SO_USER@$IP:$MINIKUBE_FOLDER/ minikube\` <====="
# echo "=====> Usuario e senha para logar no NGINX: $SO_USER|$SUDO_PASS <====="

# echo " " 
# echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
# echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
# echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
