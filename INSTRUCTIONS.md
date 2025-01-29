Clonar todos os shell scripts para a maquina que vai receber as instalações: git clone https://github.com/RodrigoAPimentel/scripts.git

Copiar os arquivos de conexão externa gerados pela instalação do minikube: sshpass -p '<PASSWORD>' scp -o StrictHostKeyChecking=no -r <USER>@<IP>:/home/user/minikube-install/minikube/ <TARGET_FOLDER>

------------------------ MINIKUBE DASHBOARD

minikube dashboard
kubectl proxy --port=8888 --address='0.0.0.0' --disable-filter=true

http://<IP MINIKUBE VM>:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/

---

[Unit]
Description=minitunnel
After=network-online.target minikube.service
Wants=network-online.target minikube.service
Requires=minikube.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/root
ExecStart=kubectl proxy --port=8888 --address='0.0.0.0' --disable-filter=true
ExecStop=/usr/local/bin/minikube stop
User=user
Group=docker

[Install]
WantedBy=multi-user.target
