SUDO_PASS=toor
SO_USER=minikube
SO_USER_GROUP=docker
IP=$(hostname -I |  awk '{print $1}')
NGINX_FOLDER=~/nginx
MINIKUBE_FOLDER=$NGINX_FOLDER/minikube

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

echo '##########################################################################'
echo '############################ INSTALL MINIKUBE ############################'
echo '##########################################################################\n'

___console_logs '[01/18] Verify Docker installed'
IS_DOCKER=$(which docker)
if [ -z "${IS_DOCKER}" ]; then
    echo "111  XXX Docker NOT installed. Docker is a basic requirement for minikube!! XXX"
    exit 1
else
    echo "111  ==> Docker INSTALLED."
fi

___console_logs '[02/18] Download Minikube'
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64

___console_logs '[03/18] Install Minikube'
echo $SUDO_PASS | sudo -S install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

___console_logs '[04/18] Download Kubectl'
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

___console_logs '[05/18] Install Kubectl'
echo $SUDO_PASS | sudo -S install -o root -g root -m 0955 kubectl /usr/local/bin/kubectl && rm kubectl && rm kubectl.sha256
kubectl version --client --output=yaml

___console_logs '[06/18] Config Docker default driver'
minikube config set driver docker

___console_logs '[07/18] Minikube Start'
minikube start --force

___console_logs '[08/18] Minikube Status'
minikube status

___console_logs '[09/18] Configure Kickoff Minikube Cluster on Machine Startup'
sudo -i -u root bash << EOF
echo $SUDO_PASS | sudo -S cat <<EOF2 > /etc/systemd/system/minikube.service
[Unit]
Description=Kickoff Minikube Cluster
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/minikube start --force
RemainAfterExit=true
ExecStop=/usr/local/bin/minikube stop
StandardOutput=journal
User=$SO_USER
Group=$SO_USER_GROUP

[Install]
WantedBy=multi-user.target
EOF2
EOF
echo $SUDO_PASS | sudo -S cat /etc/systemd/system/minikube.service56

___console_logs '[10/18] Enable Minikube Service'
systemctl enable minikube
systemctl status minikube

echo '\n--------------------------------------------------------------------------'
echo '--------------------------- CREATE NGINX PROXY ---------------------------'
echo '--------------------------------------------------------------------------\n'

___console_logs '[11/18] Copy the certificate and key'
mkdir -p $MINIKUBE_FOLDER
cp -rv ~/.minikube/profiles/minikube/client.crt $MINIKUBE_FOLDER
cp -rv ~/.minikube/profiles/minikube/client.key $MINIKUBE_FOLDER
cp -rv ~/.minikube/ca.crt $MINIKUBE_FOLDER

___console_logs '[12/18] Create NGINX password'
echo $SUDO_PASS | sudo -S apt install -yqqq apache2-utils
echo $SUDO_PASS | htpasswd -c -b -i $MINIKUBE_FOLDER/.htpasswd $SO_USER

___console_logs '[13/18] Create nginx.conf file'
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
cat $NGINX_FOLDER/nginx.conf

___console_logs '[14/18] Create Dockerfile'
cat <<EOF > $NGINX_FOLDER/Dockerfile
# Official Nginx image
FROM nginx:latest

# Copy Nginx configuration file to the container
COPY nginx.conf /etc/nginx/nginx.conf

# Copy minikube certs and password
COPY minikube/client.key /etc/nginx/certs/minikube-client.key
COPY minikube/client.crt /etc/nginx/certs/minikube-client.crt
COPY minikube/.htpasswd /etc/nginx/.htpasswd

# Expose port 80 and 443
EXPOSE 80
EXPOSE 443
EOF
cat $NGINX_FOLDER/Dockerfile

___console_logs '[15/18] Show NGINX all Files'
echo $SUDO_PASS | sudo -S apt install -yqqq tree
tree $NGINX_FOLDER

___console_logs '[16/18] Build NGINX docker image'
docker build -t nginx-minikube-proxy $NGINX_FOLDER

___console_logs '[17/18] Run NGINX docker image'
CONTAINER_ID=$(docker run -d --memory="500m" --memory-reservation="256m" --cpus="0.25" --restart=always --name nginx-minikube-proxy -p 443:443 -p 80:80 --network=minikube nginx-minikube-proxy)
echo "==> CONTAINER ID: [$CONTAINER_ID]"
docker logs $CONTAINER_ID

___console_logs '[18/18] Create Kubeconfig to external access'
cat <<EOF > $MINIKUBE_FOLDER/Kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority: ca.crt
    extensions:
    - extension:
        provider: minikube.sigs.k8s.io
        version: v1.31.2
      name: cluster_info
    server: minikube:$SUDO_PASS@$IP
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        provider: minikube.sigs.k8s.io
        version: v1.31.2
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: client.crt
    client-key: client.key
EOF
echo "=> See the Kubeconfig for external access to minikube at: $MINIKUBE_FOLDER/Kubeconfig"

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'