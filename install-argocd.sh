#! /bin/bash

# OPERATION SYSTEM 
SUDO_PASS=$1
IP=$(hostname -I |  awk '{print $1}')
# ARGOCD CONFIGURATIONS
ARGOCD_DASHBOARD_DOMAIN=minikube-argocd
ARGOCD_DASHBOARD_PORT=88

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

_log__step '[01/08] Verify Minikube installed'
IS_MINIKUBE=$(which minikube)
if [ -z "${IS_MINIKUBE}" ]; then
    _log__step_result_failed "Minikube NOT installed. Minikube is a basic requirement!!"
    exit 1
else
    _log__step_result_success "==> Minikube INSTALLED."
fi

_log__step '[02/08] Create argocd namespace'
kubectl create namespace argocd

_log__step '[03/08] Install ArgoCD'
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.5.8/manifests/install.yaml
echo "----------"
_log__step_result_suggestion "> Wait pod argocd-server is Running ....."
kubectl -n argocd wait --for=jsonpath='{.status.phase}'=Running pod -l app.kubernetes.io/name=argocd-server --timeout=10m
echo "----------"
_log__step_result_success "$(kubectl get all -n argocd)"

_log__step '[04/08] Download and Install argocd-cli'
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
echo $SUDO_PASS | sudo -S install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
_log__step_result_success "$(rm -v argocd-linux-amd64)"

_log__step '[05/08] Configure iptable'
RUNNING_MINIKUBE_IP=$(minikube ip)
echo $SUDO_PASS | sudo -S iptables -t nat -A PREROUTING -p tcp --dport $ARGOCD_DASHBOARD_PORT -j DNAT --to-destination $RUNNING_MINIKUBE_IP:80
echo $SUDO_PASS | sudo -S iptables -A FORWARD -p tcp -d $RUNNING_MINIKUBE_IP --dport 80 -j ACCEPT
echo $SUDO_PASS | sudo -S sh -c 'iptables-save > /etc/iptables/rules.v4'
echo $SUDO_PASS | sudo -S sh -c 'ip6tables-save > /etc/iptables/rules.v6'
_log__step_result_success "$(cat /etc/iptables/rules.v4 | grep -E "PREROUTING.*$ARGOCD_DASHBOARD_PORT")"
echo "----------"
_log__step_result_success "$(cat /etc/iptables/rules.v4 | grep -E "FORWARD.*$RUNNING_MINIKUBE_IP")"

_log__step '[06/08] Create ArgoCD Ingress'
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
  - host: $ARGOCD_DASHBOARD_DOMAIN
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: argocd-server
            port:
              name: http
EOF
_log__cat_file "ingress-argocd-dashboard.yaml" "$(cat ingress-argocd-dashboard.yaml)" "$pwd/ingress-argocd-dashboard.yaml"
_log__step_result_success "$(kubectl apply -f ingress-argocd-dashboard.yaml)"
echo "----------"
_log__step_result_success "$(kubectl get ingress -n argocd)"
echo "----------"
_log__step_result_success "$(rm -v ingress-argocd-dashboard.yaml)"

_log__step '[07/08] Disable TLS and enable SSL-PASSTHROUGH to access Dashboard externally'
kubectl -n argocd patch deployment argocd-server --type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/command/-", "value": "--insecure2"}]'
_log__step_result_success "$(kubectl -n argocd describe deployment argocd-server | grep -A 3 Command)"
echo "----------"
kubectl -n ingress-nginx patch deployment ingress-nginx-controller --type=json -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--enable-ssl-passthrough"}]'
_log__step_result_success "$(kubectl -n ingress-nginx describe deployment ingress-nginx-controller | grep -A 12 Args)"

_log__step '[08/08] Informations'
ARGOCD_INITIAL_PASS=$(argocd admin initial-password -n argocd)
_log__step_result_success "=====> Usuário e senha para logar no ArgoCD Dashboard: admin|$ARGOCD_INITIAL_PASS"
echo "----------"
_log__step_result_success """
=====> ArgoCD Dashboard: 
          1. Adicionar ao arquivos de host (Ex. Win: C:\Windows\System32\drivers\etc\hosts): 
                $IP          $ARGOCD_DASHBOARD_DOMAIN
          2. No navegador:
                http://$ARGOCD_DASHBOARD_DOMAIN:$ARGOCD_DASHBOARD_PORT 
"""

_log__finish_information