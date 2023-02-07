___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

echo '##########################################################################'
echo '################# INITIAL MACHINE PREPARATION [CentOS 8] #################'
echo '##########################################################################'

___console_logs 'Fix Failed to download metadata for repo ...'
cd /etc/yum.repos.d/
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

___console_logs 'Adding EPEL repository ...'
dnf install -y epel-release

___console_logs 'Updating the system package repository cache ...'
dnf -y makecache

___console_logs 'Updating the system’s packages ...'
dnf -y update & dnf -y upgrade

___console_logs 'Installing the OpenSSH server package ...'
dnf install -y openssh-server

___console_logs 'Starting the OpenSSH service ...'
systemctl start sshd

___console_logs 'Enabling OpenSSH service ...'
systemctl enable sshd

___console_logs 'Allowing the firewall for traffic flow through the SSH ...'
firewall-cmd --zone=public --permanent --add-service=ssh

___console_logs 'Reloading the firewall after configuring ...'
firewall-cmd --reload

___console_logs 'Installing Docker ...'
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

___console_logs 'Starting the Docker service ...'
systemctl start docker

___console_logs 'Enabling Docker service ...'
systemctl enable docker

___console_logs 'Restarting the machine ...'
reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'