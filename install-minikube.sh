SUDO_PASS=toor
SO_USER=minikube
SO_USER_GROUP=docker
_HOME=${HOME}

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

# ___console_logs '[01/09] Download Minikube'
# curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64

# ___console_logs '[02/09] Install Minikube'
# echo $SUDO_PASS | sudo -S install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# ___console_logs '[03/09] Download Kubectl'
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
# echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# ___console_logs '[04/09] Install Kubectl'
# echo $SUDO_PASS | sudo -S install -o root -g root -m 0955 kubectl /usr/local/bin/kubectl && rm kubectl && rm kubectl.sha256
# kubectl version --client --output=yaml

# ___console_logs '[05/09] Config Docker default driver'
# minikube config set driver docker

# ___console_logs '[06/09] Minikube Start'
# # sudo -H -u $SO_USER bash -c 'minikube start --force'
# minikube start --force

# ___console_logs '[07/09] Minikube Status'
# minikube status

# ___console_logs '[08/09] Configure Kickoff Minikube Cluster on Machine Startup'
# sudo -i -u root bash << EOF
# echo $SUDO_PASS | sudo -S cat <<EOF2 > /etc/systemd/system/minikube.service56
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

# ___console_logs '[09/09] Enable Minikube Service'
# systemctl enable minikube
# systemctl status minikube

echo '--------------------------------------------------------------------------'
echo '--------------------------- CREATE NGINX PROXY ---------------------------'
echo '--------------------------------------------------------------------------\n'

# ___console_logs '[09/09] Copy the certificate and key'
# mkdir -p ~/nginx/minikube
# cp ~/.minikube/profiles/minikube/client.crt ~/nginx/minikube
# cp ~/.minikube/profiles/minikube/client.key ~/nginx/minikube
# cp ~/.minikube/ca.crt ~/nginx/minikube

___console_logs '[09/09] Create NGINX password'
echo $SUDO_PASS | sudo -S apt install -y apache2-utils
echo '12345' | htpasswd -c -b -i ~/nginx/minikube/.htpasswd $SO_USER




echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'