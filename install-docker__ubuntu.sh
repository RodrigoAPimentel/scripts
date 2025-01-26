___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

echo '##########################################################################'
echo '############ INSTALL DOCKER AND DOCKER-COMPOSE [Ubuntu 22.04] ############'
echo '##########################################################################\n'

___console_logs '[01/11] Update and Upgrade System'
sudo apt update && sudo apt upgrade -y

___console_logs '[02/11] Install a few prerequisite packages'
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

___console_logs '[03/11] Add the GPG key for the official Docker repository'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

___console_logs '[04/11] Add the Docker repository to APT sources'
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

___console_logs '[05/11] Update your existing list of packages again for the addition to be recognized'
sudo apt update

___console_logs '[06/11] Make sure you are about to install from the Docker repo instead of the default Ubuntu repo'
apt-cache policy docker-ce

___console_logs '[07/11] Install Docker'
sudo apt install -y docker-ce

___console_logs '[08/11] Docker Status'
sudo systemctl status docker

___console_logs '[09/11] Install Docker Compose'
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
docker compose version

___console_logs '[10/11] Add your username to the docker group'
sudo usermod -aG docker ${USER} && su - ${USER}

___console_logs '[11/11] Restarting the machine'
reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'