___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

echo '##########################################################################'
echo '############ INSTALL DOCKER AND DOCKER-COMPOSE [CentOS 8 - Stream] #######'
echo '##########################################################################\n'


___console_logs 'Installing required packages'
dnf install -y dnf-plugins-core

___console_logs 'Configuring the Docker repository'
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

___console_logs 'Installing Docker Engine'
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

___console_logs 'Activating and starting the docker service'
systemctl start docker
systemctl enable --now docker.service

___console_logs 'Installing Docker Compose'
curl -SL https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo " "
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'