SUDO_PASS=$1

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 1
}

echo '##########################################################################'
echo '############ INSTALL DOCKER AND DOCKER-COMPOSE [Ubuntu 22.04] ############'
echo '##########################################################################\n'

___console_logs '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    echo "XXX sudo password not entered!! XXX"
    echo "Sample: initial-preparation__ubuntu.sh <sudo pass>"
    exit 1
else
    echo "==> sudo password entered."
fi

___console_logs '[01/10] Update and Upgrade System'
echo $SUDO_PASS | sudo -S apt update && echo $SUDO_PASS | sudo -S apt upgrade -y

___console_logs '[02/10] Install a few prerequisite packages'
echo $SUDO_PASS | sudo -S apt install -y apt-transport-https ca-certificates curl software-properties-common

___console_logs '[03/10] Add the GPG key for the official Docker repository'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

___console_logs '[04/10] Add the Docker repository to APT sources'
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

___console_logs '[05/10] Update your existing list of packages again for the addition to be recognized'
echo $SUDO_PASS | sudo -S apt update

___console_logs '[06/10] Make sure you are about to install from the Docker repo instead of the default Ubuntu repo'
apt-cache policy docker-ce

___console_logs '[07/10] Install Docker'
echo $SUDO_PASS | sudo -S apt install -y docker-ce

___console_logs '[08/10] Install Docker Compose'
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
docker compose version

___console_logs '[09/10] Add your username to the docker group'
echo $SUDO_PASS | sudo -S usermod -aG docker ${USER}

___console_logs '[10/10] Restarting the machine'
echo $SUDO_PASS | sudo -S reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
