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

SUDO_PASS=$1

# ___console_logs '[01/07] Download Minikube'
# curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64

# ___console_logs '[02/07] Install Minikube'
# echo $SUDO_PASS | sudo -S install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# ___console_logs '[03/07] Download Kubectl'
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
# echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# ___console_logs '[04/07] Install Kubectl'
# echo $SUDO_PASS | sudo -S install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl && rm kubectl.sha256
# kubectl version --client --output=yaml

# ___console_logs '[05/07] Config Docker default driver'
# minikube config set driver docker

# ___console_logs '[06/07] Minikube Start'
# minikube start --force

# ___console_logs '[07/07] Minikube Status'
# minikube status











___console_logs 'Configure Kickoff Minikube Cluster on Machine Startup'
echo $SUDO_PASS | sudo -S touch /etc/systemd/system/minikube.service

___console_logs 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'
echo toor | sudo -S cat <<EOF > /etc/systemd/system/minikube.service
[Unit]
Description=Kickoff Minikube Cluster
After=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/minikube start --force
RemainAfterExit=true
ExecStop=/usr/local/bin/minikube stop
StandardOutput=journal
User=minikube
Group=docker

[Install]
WantedBy=multi-user.target
EOF
# systemctl enable minikube

# ___console_logs '[07/07] Minikube Service Status'
# systemctl status minikube


___console_logs 'PPPPPPPPPPPPPPPPPPPPPPP'
systemctl cat /etc/systemd/system/minikube.service









echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'