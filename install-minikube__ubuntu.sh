# #! /bin/bash

# # OPERATION SYSTEM 
# SUDO_PASS=$1
# OS_USER=$(echo ${USER})
# OS_USER_GROUP=docker
# IP=$(hostname -I |  awk '{print $1}')
# # MINIKUBE - PATHS
# MINIKUBE_INSTALL_ROOT_FOLDER=$HOME/minikube-install
# MINIKUBE_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/minikube
# NGINX_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/nginx
# # MINIKUBE - CONFIGURATION
# KUBERNETES_DASHBOARD_DOMAIN=k8s-minikube-dashboard
# KUBERNETES_DASHBOARD_PORT=88
# MINIKUBE_ADDONS=ingress,ingress-dns,dashboard

source ./_logs.sh

# script_start "INSTALL MINIKUBE"

# step '[--] Check if the sudo password was entered'
# if [ -z "${SUDO_PASS}" ]; then
#     step_result_failed "sudo password not entered!!"
#     step_result_suggestion "Sample: install-minikube__ubuntu.sh <sudo pass>"
#     exit 1
# else
#     step_result_success "==> sudo password entered."
# fi

# step '[01/19] Verify Docker installed'
# IS_DOCKER=$(which docker)
# if [ -z "${IS_DOCKER}" ]; then
#     step_result_failed "Docker NOT installed. Docker is a basic requirement for minikube!!"
#     exit 1
# else
#     step_result_success "==> Docker INSTALLED."
# fi

# step '[02/19] Install a few prerequisite packages [tree yq iptables-persistent]'
# echo $SUDO_PASS | sudo -S DEBIAN_FRONTEND=noninteractive apt install -yqqq tree yq iptables-persistent

# step '[03/19] Download and Install Minikube'
# curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
# echo "----------"
# echo $SUDO_PASS | sudo -S install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
# step_result_success $(which minikube)

# step '[04/19] Download and Install Kubectl'
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
# echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
# echo "----------"
# echo $SUDO_PASS | sudo -S install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl && rm kubectl.sha256
step_result_success $(kubectl version --client --output=yaml)

# step '[05/19] Config Minikube Docker default driver'
# minikube config set driver docker

# step '[06/19] Minikube Start'
# minikube start --addons=$MINIKUBE_ADDONS --force
# # echo "----------"
# step_result_success $(minikube status)

# step '[07/19] Configure Kickoff Minikube Cluster on Machine Startup'
# sudo -i -u root bash << EOF
# echo $SUDO_PASS | sudo -S cat <<EOF2 > /etc/systemd/system/minikube.service
# [Unit]
# Description=Kickoff Minikube Cluster
# After=docker.service

# [Service]
# Type=oneshot
# ExecStart=/usr/local/bin/minikube start --addons=$MINIKUBE_ADDONS --force
# RemainAfterExit=true
# ExecStop=/usr/local/bin/minikube stop
# StandardOutput=journal
# User=$OS_USER
# Group=$OS_USER_GROUP

# [Install]
# WantedBy=multi-user.target
# EOF2
# EOF
# # step_result "========================= [minikube.service] ========================="
# # step_result_success $(echo $SUDO_PASS | sudo -S cat /etc/systemd/system/minikube.service)
# # step_result "====================================================================== [/etc/systemd/system/minikube.service]"
# cat_file "minikube.service" "$(echo $SUDO_PASS | sudo -S cat /etc/systemd/system/minikube.service)" "/etc/systemd/system/minikube.service"

# step '[08/19] Enable Minikube Service'
# step_result_success $(echo $SUDO_PASS | sudo -S systemctl enable minikube)

# echo '\n--------------------------------------------------------------------------'
# echo '--------------------------- CREATE NGINX PROXY ---------------------------'
# echo '--------------------------------------------------------------------------'

# step '[09/19] Copy the certificates and keys'
# mkdir -p $MINIKUBE_FOLDER
# mkdir -p $NGINX_FOLDER
# cp -rv $HOME/.minikube/profiles/minikube/client.crt $MINIKUBE_FOLDER
# cp -rv $HOME/.minikube/profiles/minikube/client.key $MINIKUBE_FOLDER
# cp -rv $HOME/.minikube/ca.crt $MINIKUBE_FOLDER

# step '[10/19] Create NGINX password'
# echo $SUDO_PASS | sudo -S apt install -yqqq apache2-utils
# echo $SUDO_PASS | htpasswd -c -b -i $NGINX_FOLDER/.htpasswd $OS_USER

# step '[11/19] Create nginx.conf file'
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
# # echo "============================ [nginx.conf] ============================"
# # cat $NGINX_FOLDER/nginx.conf
# # echo "====================================================================== [$NGINX_FOLDER/nginx.conf]"
# cat_file "nginx.conf" "$(cat $NGINX_FOLDER/nginx.conf)" "$NGINX_FOLDER/nginx.conf"

# step '[12/19] Create Dockerfile'
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
# # echo "============================ [Dockerfile] ============================"
# # cat $NGINX_FOLDER/Dockerfile
# # echo "====================================================================== [$NGINX_FOLDER/Dockerfile]"
# cat_file "Dockerfile" "$(cat $NGINX_FOLDER/Dockerfile)" "$NGINX_FOLDER/Dockerfile"

# step '[13/19] Build NGINX docker image'
# docker build -t nginx-minikube-proxy -f $NGINX_FOLDER/Dockerfile $MINIKUBE_INSTALL_ROOT_FOLDER

# step '[14/19] Run NGINX docker image'
# OLD_CONTAINER_DELETED=$(docker rm --force nginx-minikube-proxy 2> /dev/null)
# CONTAINER_ID=$(docker run -d --memory="500m" --memory-reservation="256m" --cpus="0.25" --restart=always --name nginx-minikube-proxy -p 443:443 -p 80:80 --network=minikube nginx-minikube-proxy)
# step_result_success "=====> OLD CONTAINER DELETED: [$OLD_CONTAINER_DELETED]"
# echo "----------"
# step_result_success "=====> CONTAINER ID: [$CONTAINER_ID]"
# echo "----------"
# step_result_success "=====> Container NGINX logs:"
# step_result_success $(docker logs $CONTAINER_ID)

# step '[15/19] Configure Kubeconfig to external access'
# cp -rv $HOME/.kube/config $MINIKUBE_FOLDER/kubeconfig
# yq -yi ".clusters[0].cluster.server = \"$OS_USER:$SUDO_PASS@$IP:443\"" $MINIKUBE_FOLDER/kubeconfig 
# yq -yi '.clusters[0].cluster."certificate-authority" = "ca.crt"' $MINIKUBE_FOLDER/kubeconfig
# yq -yi '.users[0].user."client-certificate" = "client.crt"' $MINIKUBE_FOLDER/kubeconfig
# yq -yi '.users[0].user."client-key" = "client.key"' $MINIKUBE_FOLDER/kubeconfig
# echo "----------"
# # echo "============================ [kubeconfig] ============================"
# # cat $MINIKUBE_FOLDER/kubeconfig
# # echo "====================================================================== [$MINIKUBE_FOLDER/kubeconfig]"
# cat_file "kubeconfig" "$(cat $MINIKUBE_FOLDER/kubeconfig)" "$MINIKUBE_FOLDER/kubeconfig"
# echo "----------"
# step_result_suggestion "=====> See the Kubeconfig for external access to minikube at: $MINIKUBE_FOLDER/Kubeconfig"

# step '[16/19] Show all Configuration Files'
# step_result_success $(tree -a $MINIKUBE_INSTALL_ROOT_FOLDER)

# echo '\n--------------------------------------------------------------------------'
# echo '--------------------- CONFIGURE KUBERNETES DASHBOARD ---------------------'
# echo '--------------------------------------------------------------------------'

# step '[17/19] Create Kubernetes Dashboard Ingress'
# cat <<EOF > ingress-kubernetes-dashboard.yaml
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: kubernetes-dashboard-ingress
#   namespace: kubernetes-dashboard
# spec:
#   rules:
#   - host: $KUBERNETES_DASHBOARD_DOMAIN
#     http:
#       paths:
#       - path: /
#         pathType: Prefix
#         backend:
#           service:
#             name: kubernetes-dashboard
#             port: 
#               number: 80
# EOF
# # echo "========================= [ingress-kubernetes-dashboard.yaml] ========================="
# # cat ingress-kubernetes-dashboard.yaml
# # echo "====================================================================== [$pwd/ingress-kubernetes-dashboard.yaml]"
# cat_file "ingress-kubernetes-dashboard.yaml" "$(cat ingress-kubernetes-dashboard.yaml)" "$pwd/ingress-kubernetes-dashboard.yaml"
# echo "----------"
# step_result_success $(kubectl apply -f ingress-kubernetes-dashboard.yaml)
# echo "----------"
# step_result_success $(kubectl get ingress -n kubernetes-dashboard)
# echo "----------"
# step_result_success $(rm -v ingress-kubernetes-dashboard.yaml)

# step '[18/19] Configure iptable'
# RUNNING_MINIKUBE_IP=$(minikube ip)
# echo $SUDO_PASS | sudo -S iptables -t nat -A PREROUTING -p tcp --dport $KUBERNETES_DASHBOARD_PORT -j DNAT --to-destination $RUNNING_MINIKUBE_IP:80
# echo $SUDO_PASS | sudo -S iptables -A FORWARD -p tcp -d $RUNNING_MINIKUBE_IP --dport 80 -j ACCEPT
# echo $SUDO_PASS | sudo -S sh -c 'iptables-save > /etc/iptables/rules.v4'
# echo $SUDO_PASS | sudo -S sh -c 'ip6tables-save > /etc/iptables/rules.v6'
# step_result_success $(cat /etc/iptables/rules.v4 | grep -E "PREROUTING.*$KUBERNETES_DASHBOARD_PORT")
# echo "----------"
# step_result_success $(cat /etc/iptables/rules.v4 | grep -E "FORWARD.*$RUNNING_MINIKUBE_IP")

# step '[19/19] Informations'
# step_result_success "=====> See the Kubeconfig for external access to minikube at: $MINIKUBE_FOLDER/Kubeconfig"
# echo "----------"
# step_result_success "=====> Copiar os arquivos de conexão externa gerados pela instalação do minikube: \`sshpass -p '$SUDO_PASS' scp -o StrictHostKeyChecking=no -r $OS_USER@$IP:$MINIKUBE_FOLDER/ minikube\`"
# echo "----------"
# step_result_success "=====> Usuario e senha para logar no NGINX proxy: $OS_USER|$SUDO_PASS"
# echo "----------"
# step_result_success """
# =====> Kubernetes Dashboard: 
#           1. Adicionar ao arquivos de host (Ex. Win: C:\Windows\System32\drivers\etc\hosts): 
#                 $IP    $KUBERNETES_DASHBOARD_DOMAIN
#           2. No navegador:
#                 http://$KUBERNETES_DASHBOARD_DOMAIN:$KUBERNETES_DASHBOARD_PORT 
# """

# finish_information
