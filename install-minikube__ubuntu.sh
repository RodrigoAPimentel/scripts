SUDO_PASS=$1
SO_USER=$(echo ${USER})
SO_USER_GROUP=docker
IP=$(hostname -I |  awk '{print $1}')
MINIKUBE_INSTALL_ROOT_FOLDER=$HOME/minikube-install
MINIKUBE_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/minikube
NGINX_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/nginx
KUBERNETES_DASHBOARD_DOMAIN=k8s-minikube-dashboard
KUBERNETES_DASHBOARD_PORT=88

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 1
}

echo '##########################################################################'
echo '############################ INSTALL MINIKUBE ############################'
echo '##########################################################################\n'

___console_logs '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    echo "XXX sudo password not entered!! XXX"
    echo "Sample: install-minikube__ubuntu.sh <sudo pass>"
    exit 1
else
    echo "==> sudo password entered."
fi

___console_logs '[01/22] Install a few prerequisite packages'
echo $SUDO_PASS | sudo -S DEBIAN_FRONTEND=noninteractive apt install -yqqq tree yq iptables-persistent

___console_logs '[02/22] Verify Docker installed'
IS_DOCKER=$(which docker)
if [ -z "${IS_DOCKER}" ]; then
    echo "XXX Docker NOT installed. Docker is a basic requirement for minikube!! XXX"
    exit 1
else
    echo "==> Docker INSTALLED."
fi

___console_logs '[03/22] Download Minikube'
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64

___console_logs '[04/22] Install Minikube'
echo $SUDO_PASS | sudo -S install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
which minikube

___console_logs '[05/22] Download Kubectl'
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

___console_logs '[06/22] Install Kubectl'
echo $SUDO_PASS | sudo -S install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl && rm kubectl.sha256
kubectl version --client --output=yaml

___console_logs '[07/22] Config Docker default driver'
minikube config set driver docker

___console_logs '[08/22] Minikube Start'
minikube start --addons=ingress,ingress-dns,dashboard --force

___console_logs '[09/22] Minikube Status'
minikube status

___console_logs '[10/22] Configure Kickoff Minikube Cluster on Machine Startup'
sudo -i -u root bash << EOF
echo $SUDO_PASS | sudo -S cat <<EOF2 > /etc/systemd/system/minikube.service
[Unit]
Description=Kickoff Minikube Cluster
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/minikube start --addons=ingress,ingress-dns,dashboard --force
RemainAfterExit=true
ExecStop=/usr/local/bin/minikube stop
StandardOutput=journal
User=$SO_USER
Group=$SO_USER_GROUP

[Install]
WantedBy=multi-user.target
EOF2
EOF
echo "========================= [minikube.service] ========================="
echo $SUDO_PASS | sudo -S cat /etc/systemd/system/minikube.service
echo "====================================================================== [/etc/systemd/system/minikube.service]"

___console_logs '[11/22] Enable Minikube Service'
echo $SUDO_PASS | sudo -S systemctl enable minikube
systemctl status minikube

echo '\n--------------------------------------------------------------------------'
echo '--------------------- CONFIGURE KUBERNETES DASHBOARD ---------------------'
echo '--------------------------------------------------------------------------'

___console_logs '[12/22] Create Kubernetes Dashboard Ingress'
cat <<EOF > ingress-kubernetes-dashboard.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubernetes-dashboard-ingress
  namespace: kubernetes-dashboard
spec:
  rules:
  - host: $KUBERNETES_DASHBOARD_DOMAIN
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard
            port: 
              number: 80
EOF
echo "========================= [minikube.service] ========================="
cat ingress-kubernetes-dashboard.yaml
echo "====================================================================== [ingress-kubernetes-dashboard.yaml]"
echo "----------"
kubectl apply -f ingress-kubernetes-dashboard.yaml
echo "----------"
kubectl get ingress -n kubernetes-dashboard
echo "----------"
rm -v ingress-kubernetes-dashboard.yaml

___console_logs '[13/22] Configure iptable'
RUNNING_MINIKUBE_IP=$(minikube ip)
echo $SUDO_PASS | sudo -S iptables -t nat -A PREROUTING -p tcp --dport $KUBERNETES_DASHBOARD_PORT -j DNAT --to-destination $RUNNING_MINIKUBE_IP:80
echo $SUDO_PASS | sudo -S iptables -A FORWARD -p tcp -d $RUNNING_MINIKUBE_IP --dport 80 -j ACCEPT
echo $SUDO_PASS | sudo -S sh -c 'iptables-save > /etc/iptables/rules.v4'
echo $SUDO_PASS | sudo -S sh -c 'ip6tables-save > /etc/iptables/rules.v6'
cat /etc/iptables/rules.v4 | grep -E "PREROUTING.*$KUBERNETES_DASHBOARD_PORT"
echo "----------"
cat /etc/iptables/rules.v4 | grep -E "FORWARD.*$RUNNING_MINIKUBE_IP"

echo '\n--------------------------------------------------------------------------'
echo '--------------------------- CREATE NGINX PROXY ---------------------------'
echo '--------------------------------------------------------------------------'

___console_logs '[14/22] Copy the certificate and key'
mkdir -p $MINIKUBE_FOLDER
mkdir -p $NGINX_FOLDER
cp -rv $HOME/.minikube/profiles/minikube/client.crt $MINIKUBE_FOLDER
cp -rv $HOME/.minikube/profiles/minikube/client.key $MINIKUBE_FOLDER
cp -rv $HOME/.minikube/ca.crt $MINIKUBE_FOLDER

___console_logs '[15/22] Create NGINX password'
echo $SUDO_PASS | sudo -S apt install -yqqq apache2-utils
echo $SUDO_PASS | htpasswd -c -b -i $NGINX_FOLDER/.htpasswd $SO_USER

___console_logs '[16/22] Create nginx.conf file'
cat <<EOF > $NGINX_FOLDER/nginx.conf
events {
    worker_connections 1024;
}
http {
  server_tokens off;
  auth_basic "Administrator’s Area";
  auth_basic_user_file /etc/nginx/.htpasswd;
  server {
    listen 443;
    server_name minikube;
    location / {
      proxy_set_header X-Forwarded-For \$remote_addr;
      proxy_set_header Host            \$http_host;
      proxy_pass https://minikube:8443;
      proxy_ssl_certificate /etc/nginx/certs/minikube-client.crt;
      proxy_ssl_certificate_key /etc/nginx/certs/minikube-client.key;
    }
  }
}
EOF
echo "============================ [nginx.conf] ============================"
cat $NGINX_FOLDER/nginx.conf
echo "====================================================================== [$NGINX_FOLDER/nginx.conf]"

___console_logs '[17/22] Create Dockerfile'
cat <<EOF > $NGINX_FOLDER/Dockerfile
# Official Nginx image
FROM nginx:latest

# Copy Nginx configuration file to the container
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy minikube certs and password
COPY  minikube/client.key /etc/nginx/certs/minikube-client.key
COPY  minikube/client.crt /etc/nginx/certs/minikube-client.crt
COPY nginx/.htpasswd /etc/nginx/.htpasswd

# Expose port 80 and 443
EXPOSE 80
EXPOSE 443
EOF
echo "============================ [Dockerfile] ============================"
cat $NGINX_FOLDER/Dockerfile
echo "====================================================================== [$NGINX_FOLDER/Dockerfile]"

___console_logs '[18/22] Build NGINX docker image'
docker build -t nginx-minikube-proxy -f $NGINX_FOLDER/Dockerfile $MINIKUBE_INSTALL_ROOT_FOLDER

___console_logs '[19/22] Run NGINX docker image'
OLD_CONTAINER_DELETED=$(docker rm --force nginx-minikube-proxy)
CONTAINER_ID=$(docker run -d --memory="500m" --memory-reservation="256m" --cpus="0.25" --restart=always --name nginx-minikube-proxy -p 443:443 -p 80:80 --network=minikube nginx-minikube-proxy)
echo "=====> OLD CONTAINER DELETED: [$OLD_CONTAINER_DELETED] <====="
echo "=====> CONTAINER ID: [$CONTAINER_ID] <====="
echo "=====> Container NGINX logs: <====="
docker logs $CONTAINER_ID

___console_logs '[20/22] Configure Kubeconfig to external access'
cp -rv $HOME/.kube/config $MINIKUBE_FOLDER/kubeconfig
yq -yi ".clusters[0].cluster.server = \"$SO_USER:$SUDO_PASS@$IP:443\"" $MINIKUBE_FOLDER/kubeconfig 
yq -yi '.clusters[0].cluster."certificate-authority" = "ca.crt"' $MINIKUBE_FOLDER/kubeconfig
yq -yi '.users[0].user."client-certificate" = "client.crt"' $MINIKUBE_FOLDER/kubeconfig
yq -yi '.users[0].user."client-key" = "client.key"' $MINIKUBE_FOLDER/kubeconfig
echo "============================ [kubeconfig] ============================"
cat $MINIKUBE_FOLDER/kubeconfig
echo "====================================================================== [$MINIKUBE_FOLDER/kubeconfig]"
echo "=====> See the Kubeconfig for external access to minikube at: $MINIKUBE_FOLDER/Kubeconfig <====="

___console_logs '[21/22] Show all Configuration Files'
tree -a $MINIKUBE_INSTALL_ROOT_FOLDER

___console_logs '[22/22] Informations'
echo "=====> Copiar os arquivos de conexão externa gerados pela instalação do minikube: \`sshpass -p '$SUDO_PASS' scp -o StrictHostKeyChecking=no -r $SO_USER@$IP:$MINIKUBE_FOLDER/ minikube\` <====="
echo "=====> Usuario e senha para logar no NGINX proxy: $SO_USER|$SUDO_PASS <====="
echo """
=====> Kubernetes Dashboard: 
          1. Adicionar ao arquivos de host (Ex. Win: C:\Windows\System32\drivers\etc\hosts): 
                $IP    $KUBERNETES_DASHBOARD_DOMAIN
          2. No navegador:
                http://$KUBERNETES_DASHBOARD_DOMAIN:$KUBERNETES_DASHBOARD_PORT 
<=====
"""

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
