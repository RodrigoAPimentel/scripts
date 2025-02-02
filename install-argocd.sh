#! /bin/bash

# OPERATION SYSTEM 
SUDO_PASS=$1
OS_USER=$(echo ${USER})
OS_USER_GROUP=docker
IP=$(hostname -I |  awk '{print $1}')
# MINIKUBE - PATHS
MINIKUBE_INSTALL_ROOT_FOLDER=$HOME/minikube-install
MINIKUBE_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/minikube
NGINX_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/nginx
# MINIKUBE - CONFIGURATION
KUBERNETES_DASHBOARD_DOMAIN=k8s-minikube-dashboard
KUBERNETES_DASHBOARD_PORT=88
MINIKUBE_ADDONS=ingress,ingress-dns,dashboard

# LOADING LOG FUNCTIONS FILE
. ./_logs.sh

_log__script_start "INSTALL ARGOCD"

_log__step '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    _log__step_result_failed "sudo password not entered!!"
    _log__step_result_suggestion "Sample: install-minikube__ubuntu.sh <sudo pass>"
    exit 1
else
    _log__step_result_success "==> sudo password entered."
fi

_log__step '[01/20] Verify Minikube installed'
IS_MINIKUBE=$(which minikube)
if [ -z "${IS_MINIKUBE}" ]; then
    _log__step_result_failed "Minikube NOT installed. Minikube is a basic requirement!!"
    exit 1
else
    _log__step_result_success "==> Minikube INSTALLED."
fi

_log__step '[02/20] Create argocd namespace'
kubectl create namespace argocd

_log__step '[03/20] Install ArgoCD'
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "----------"
_log__step_result_success "$(kubectl get pods -n argocd)"

_log__step '[04/20] Download and Install argocd-cli'
# curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
# echo "----------"
# echo $SUDO_PASS | sudo -S install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
# echo "----------"
# rm -v argocd-linux-amd64
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.5.8/manifests/install.yaml



# _log__step '[04/20] Configure Access The Argo CD API Server'
# kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443 ######################################################################

_log__step '[20/20] Informations'
ARGOCD_INITIAL_PASS=$(argocd admin initial-password -n argocd)
_log__step_result_success "=====> ArgoCD Initial Password: $ARGOCD_INITIAL_PASS"

_log__finish_information