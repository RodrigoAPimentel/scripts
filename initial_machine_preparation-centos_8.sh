echo '##########################################################################'
echo '################# INITIAL MACHINE PREPARATION [CentOS 8] #################'
echo '##########################################################################'

echo '>>>>>>>>> Adding EPEL repository ...'
dnf install -y epel-release

echo '>>>>>>>>> Updating the system package repository cache ...'
dnf -y makecache

echo '>>>>>>>>> Updating the system’s packages ...'
dnf -y update & dnf -y upgrade

echo '>>>>>>>>> Installing the OpenSSH server package ...'
dnf install -y openssh-server

echo '>>>>>>>>> Starting the OpenSSH service ...'
systemctl start sshd

echo '>>>>>>>>> Enabling OpenSSH service ...'
systemctl enable sshd

echo '>>>>>>>>> Allowing the firewall for traffic flow through the SSH ...'
firewall-cmd --zone=public --permanent --add-service=ssh

echo '>>>>>>>>> Reloading the firewall after configuring ...'
firewall-cmd --reload

echo '>>>>>>>>> Installing Docker ...'
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

echo '>>>>>>>>> Starting the Docker service ...'
systemctl start docker

echo '>>>>>>>>> Enabling Docker service ...'
systemctl enable docker

echo '>>>>>>>>> Restarting the machine ...'
reboot --force