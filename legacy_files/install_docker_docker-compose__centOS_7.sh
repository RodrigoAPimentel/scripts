___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

echo '##########################################################################'
echo '############## INSTALL DOCKER AND DOCKER-COMPOSE [CentOS 7] ##############'
echo '##########################################################################\n'

___console_logs 'Installing required packages'
yum install -y yum-utils device-mapper-persistent-data lvm2

___console_logs 'Configuring the Docker repository'
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

___console_logs 'Installing Docker Engine'
yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

___console_logs 'Activating and starting the docker service'
systemctl start docker
systemctl enable docker

___console_logs 'Installing Docker Compose'
curl -SL https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo " "
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'