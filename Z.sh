#! /bin/bash

# OPERATION SYSTEM 
SUDO_PASS=$1
SO_USER=$(echo ${USER})
SO_USER_GROUP=docker
IP=$(hostname -I |  awk '{print $1}')
# MINIKUBE - PATHS
MINIKUBE_INSTALL_ROOT_FOLDER=$HOME/minikube-install
MINIKUBE_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/minikube
NGINX_FOLDER=$MINIKUBE_INSTALL_ROOT_FOLDER/nginx
# MINIKUBE - CONFIGURATION
KUBERNETES_DASHBOARD_DOMAIN=k8s-minikube-dashboard
KUBERNETES_DASHBOARD_PORT=88
MINIKUBE_ADDONS=ingress,ingress-dns,dashboard

source ./_logs.sh

# echo '##########################################################################'
# echo '############################ INSTALL MINIKUBE ############################'
# echo '##########################################################################\n'

script_start "INSTALL MINIKUBE"


step '[--] Check if the sudo password was entered XX' "888888888888888888888888"
if [ -z "${SUDO_PASS}" ]; then
    step_result_failed "sudo password not entered!!"
    step_result_suggestion "Sample: install-minikube__ubuntu.sh <sudo pass>"
    # exit 1
else
    step_result "==> sudo password entered."
fi

step_result $(which docker)
step_result_success '456'


finish_information


cat_file "INSTRUCTIONS.md" "$(cat INSTRUCTIONS.md)" "~/asdf/6789"


step_result_success 'AASSCCVV'