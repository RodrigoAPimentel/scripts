Clonar todos os shell scripts para a maquina que vai receber as instalações: git clone https://github.com/RodrigoAPimentel/scripts.git

Copiar os arquivos de conexão externa gerados pela instalação do minikube: scp -r minikube@192.168.99.11:/home/minikube/nginx/minikube/ target_folder
