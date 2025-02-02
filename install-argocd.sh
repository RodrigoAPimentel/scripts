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

echo '##########################################################################'
echo '############################# INSTALL ARGOCD #############################'
echo '##########################################################################\n'

___console_logs '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    echo "XXX sudo password not entered!! XXX"
    echo "Sample: install-minikube__ubuntu.sh <sudo pass>"
    exit 1
else
    echo "==> sudo password entered."
fi

___console_logs '[01/20] Verify Minikube installed'
IS_MINIKUBE=$(which minikube)
if [ -z "${IS_MINIKUBE}" ]; then
    echo "\`XXX Minikube NOT installed. Minikube is a basic requirement!! XXX\`"
    exit 1
else
    echo "==> Minikube INSTALLED."
fi

___console_logs '[02/20] Create argocd namespace'
kubectl create namespace argocd

___console_logs '[03/20] Install ArgoCD'
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd

___console_logs '[04/20] Download argocd-cli'
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

___console_logs '[05/20] Install argocd-cli'
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm -v argocd-linux-amd64

# ___console_logs '[04/20] Configure Access The Argo CD API Server'
# kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443 ######################################################################

___console_logs '[20/20] Informations'
ARGOCD_INITIAL_PASS=$(argocd admin initial-password -n argocd)
echo "=====> ArgoCD Initial Password: $ARGOCD_INITIAL_PASS"

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'











apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
spec:
  rules:
  - host: k8s-minikube
    http:
      paths:
      - path: /argocd
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard
            port: 
              number: 80