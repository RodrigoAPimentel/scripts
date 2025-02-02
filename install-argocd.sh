#! /bin/bash

# OPERATION SYSTEM 
SUDO_PASS=$1

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

_log__step '[01/06] Verify Minikube installed'
IS_MINIKUBE=$(which minikube)
if [ -z "${IS_MINIKUBE}" ]; then
    _log__step_result_failed "Minikube NOT installed. Minikube is a basic requirement!!"
    exit 1
else
    _log__step_result_success "==> Minikube INSTALLED."
fi

_log__step '[02/06] Create argocd namespace'
kubectl create namespace argocd

_log__step '[03/06] Install ArgoCD'
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.5.8/manifests/install.yaml
echo "----------"
_log__step_result_success "$(kubectl get all -n argocd)"

_log__step '[04/06] Download and Install argocd-cli'
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
echo "----------"
echo $SUDO_PASS | sudo -S install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
echo "----------"
_log__step_result_success "$(rm -v argocd-linux-amd64)"




_log__step '[05/06] Configure Access The Argo CD API Server and GUI'
# kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443 ######################################################################





_log__step '[06/06] Informations'
ARGOCD_INITIAL_PASS=$(argocd admin initial-password -n argocd)
_log__step_result_success "=====> ArgoCD Initial Password: $ARGOCD_INITIAL_PASS"

_log__finish_information