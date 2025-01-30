Clonar todos os shell scripts para a maquina que vai receber as instalações: git clone https://github.com/RodrigoAPimentel/scripts.git

Copiar os arquivos de conexão externa gerados pela instalação do minikube: sshpass -p '<PASSWORD>' scp -o StrictHostKeyChecking=no -r <USER>@<IP>:/home/user/minikube-install/minikube/ <TARGET_FOLDER>

------------------------ ARGOCD INSTALL
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl get pods -n argocd

--- ARGOCD-CLI INSTALL
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

---

<!-- kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}' -->

ARGOCD_INITIAL_PASS=$(argocd admin initial-password -n argocd)
echo ">>> ARGOCD INITIAL PASS: $ARGOCD_INITIAL_PASS"

kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443

PSqnl8ga4rmaFTsp
