# ___console_logs () {
#     echo " "
#     echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
#     echo ">>>>>>>>> $1 ..."
#     echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
#     sleep 2
# }

# echo '##########################################################################'
# echo '############ INSTALL DOCKER AND DOCKER-COMPOSE [CentOS 8 - Stream] #######'
# echo '##########################################################################\n'


# ___console_logs 'Installing required packages'
# dnf install -y dnf-plugins-core

# ___console_logs 'Configuring the Docker repository'
# dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

# ___console_logs 'Installing Docker Engine'
# dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin


# echo " "
# echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
# echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
# echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'




___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

echo '##########################################################################'
echo '###################### INITIAL MACHINE PREPARATION #######################'
echo '##########################################################################\n'

___console_logs 'Setting language variables'
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_COLLATE=C
export LC_CTYPE=en_US.UTF-8

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
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

___console_logs '[08/11] Docker Status'
sudo systemctl status docker

# ___console_logs 'Activating and starting the docker service'
# systemctl start docker
# systemctl enable --now docker.service

___console_logs '[09/11] Installing Docker Compose'
sudo curl -SL https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

___console_logs '[10/11] Add your username to the docker group'
sudo usermod -aG docker ${USER} && su - ${USER}

___console_logs '[11/11] Restarting the machine'
reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'