#! /bin/bash

##### OPERATION SYSTEM 
SUDO_PASS=$1
IP=$(hostname -I |  awk '{print $1}')
##### ARGOCD CONFIGURATIONS
# ARGOCD_VERSION=stable
ARGOCD_VERSION=v2.5.8
ARGOCD_DASHBOARD_DOMAIN=argocd-gui
ARGOCD_DASHBOARD_PORT=88

# LOADING LOG FUNCTIONS FILE
. ./_logs.sh

_script_start "INSTALL ARGOCD"
##########
_step '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    _step_result_failed "sudo password not entered!!"
    _step_result_suggestion "Sample: install-minikube__ubuntu.sh <sudo pass>"
    exit 1
else
    _step_result_success "==> sudo password entered."
fi
##########
_step '[01/08] Verify Minikube installed'
IS_MINIKUBE=$(which minikube)
if [ -z "${IS_MINIKUBE}" ]; then
    _step_result_failed "Minikube NOT installed. Minikube is a basic requirement!!"
    exit 1
else
    _step_result_success "==> Minikube INSTALLED."
fi
##########
_step '[02/08] Create argocd namespace'
kubectl create namespace argocd
##########
_step '[03/08] Install ArgoCD'
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/$ARGOCD_VERSION/manifests/install.yaml
echo "----------"
_step_result_suggestion "> Wait pod argocd-server is Running ....."
kubectl -n argocd wait --for=jsonpath='{.status.phase}'=Running pod -l app.kubernetes.io/name=argocd-server --timeout=10m
echo "----------"
_step_result_success "$(kubectl get all -n argocd)"
##########
_step '[04/08] Download and Install argocd-cli'
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
echo $SUDO_PASS | sudo -S install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
_step_result_success "$(rm -v argocd-linux-amd64)"
##########
_step '[05/08] Configure iptable'
RUNNING_MINIKUBE_IP=$(minikube ip)
echo $SUDO_PASS | sudo -S iptables -t nat -A PREROUTING -p tcp --dport $ARGOCD_DASHBOARD_PORT -j DNAT --to-destination $RUNNING_MINIKUBE_IP:80
echo $SUDO_PASS | sudo -S iptables -A FORWARD -p tcp -d $RUNNING_MINIKUBE_IP --dport 80 -j ACCEPT
echo $SUDO_PASS | sudo -S sh -c 'iptables-save > /etc/iptables/rules.v4'
echo $SUDO_PASS | sudo -S sh -c 'ip6tables-save > /etc/iptables/rules.v6'
_step_result_success "$(cat /etc/iptables/rules.v4 | grep -E "PREROUTING.*$ARGOCD_DASHBOARD_PORT")"
echo "----------"
_step_result_success "$(cat /etc/iptables/rules.v4 | grep -E "FORWARD.*$RUNNING_MINIKUBE_IP")"
##########
_step '[06/08] Create ArgoCD Ingress'
cat <<EOF > ingress-argocd-dashboard.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    alb.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: argocd-server
            port:
              name: http
    host: $ARGOCD_DASHBOARD_DOMAIN
EOF
_cat_file "ingress-argocd-dashboard.yaml" "$(cat ingress-argocd-dashboard.yaml)" "$pwd/ingress-argocd-dashboard.yaml"
_step_result_success "$(kubectl apply -f ingress-argocd-dashboard.yaml)"
echo "----------"
_step_result_success "$(kubectl get ingress -n argocd)"
echo "----------"
_step_result_success "$(rm -v ingress-argocd-dashboard.yaml)"
##########
_step '[07/08] Disable TLS and enable SSL-PASSTHROUGH to access Dashboard externally'
kubectl -n argocd patch deployment argocd-server --type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/command/-", "value": "--insecure"}]'
_step_result_success "$(kubectl -n argocd describe deployment argocd-server | grep -A 3 Command)"
echo "----------"
kubectl -n ingress-nginx patch deployment ingress-nginx-controller --type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--enable-ssl-passthrough"}]'
_step_result_success "$(kubectl -n ingress-nginx describe deployment ingress-nginx-controller | grep -A 12 Args)"
##########
_step '[08/08] Informations'
ARGOCD_INITIAL_PASS=$(argocd admin initial-password -n argocd)
_step_result_success "=====> Usuário e senha para logar no ArgoCD Dashboard: admin|$ARGOCD_INITIAL_PASS"
echo "----------"
_step_result_success """
=====> ArgoCD Dashboard: 
          1. Adicionar ao arquivos de host (Ex. Win: C:\Windows\System32\drivers\etc\hosts): 
                $IP          $ARGOCD_DASHBOARD_DOMAIN          # argocd gui
          2. No navegador:
                http://$ARGOCD_DASHBOARD_DOMAIN:$ARGOCD_DASHBOARD_PORT 
"""
##########
_finish_information