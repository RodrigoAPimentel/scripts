___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

echo '##########################################################################'
echo '##################### INSTALL ANSIBLE AWX [CentOS 7] #####################'
echo '##########################################################################'

___console_logs 'Prepare Machine'
sh ./install_docker_docker-compose__centOS_7.sh

___console_logs 'Install Required Dependency'
yum install -y nodejs npm
npm install -y npm --global
yum install -y python3-pip git pwgen wget unzip ansible

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






