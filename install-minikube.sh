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

___console_logs '[01/07] Download Minikube'
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64

___console_logs '[02/07] Install Minikube'
echo $SUDO_PASS | sudo -S install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

___console_logs '[03/07] Download Kubectl'
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

___console_logs '[04/07] Install Kubectl'
echo $SUDO_PASS | sudo -S install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml

___console_logs '[05/07] Config Docker default driver'
minikube config set driver docker

___console_logs '[06/07] Minikube Start'
minikube start --force

___console_logs '[07/07] Minikube Status'
minikube status

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'