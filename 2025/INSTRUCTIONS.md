Clonar todos os shell scripts para a maquina que vai receber as instalações: git clone https://github.com/RodrigoAPimentel/scripts.git

Copiar os arquivos de conexão externa gerados pela instalação do minikube: sshpass -p '<PASSWORD>' scp -o StrictHostKeyChecking=no -r <USER>@<IP>:/home/<USER>/nginx/minikube/ <TARGET_FOLDER>
