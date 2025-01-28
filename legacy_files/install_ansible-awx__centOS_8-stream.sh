___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

echo '##########################################################################'
echo '################ INSTALL ANSIBLE AWX [CentOS 8 - Stream] #################'
echo '##########################################################################'

___console_logs 'Installing required packages'
dnf install -y git gcc gcc-c++ nodejs gettext device-mapper-persistent-data lvm2 bzip2 python3-pip ansible dnf-plugins-core pwgen wget npm unzip
npm install -y npm --global

___console_logs 'Configuring the Docker repository'
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

___console_logs 'Installing Docker Engine'
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

___console_logs 'Activating and starting the docker service'
systemctl start docker
systemctl enable --now docker.service

___console_logs 'Set python3'
alternatives --set python /usr/bin/python3

___console_logs 'Installing Docker Compose'
curl -SL https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

___console_logs 'Download Ansible AWX [17.1.0]'
wget https://github.com/ansible/awx/archive/17.1.0.zip
unzip 17.1.0.zip

___console_logs 'Configuring Inventory file'
cd awx-17.1.0/installer
export SECRET_KEY=$(pwgen -N 1 -s 40)
sed -i "s|^admin_user=.*|admin_user=root|g" inventory
sed -i -E "s|^#([[:space:]]?)admin_password=password|admin_password=toor|g" inventory
sed -i "s|^secret_key=.*|secret_key=$SECRET_KEY|g" inventory

___console_logs 'Installing Ansible AWX'
ansible-playbook -i inventory install.yml

___console_logs 'Restarting AWX'
cd ~/.awx/awxcompose
docker-compose down
sleep 5
docker-compose up -d

echo " "
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'