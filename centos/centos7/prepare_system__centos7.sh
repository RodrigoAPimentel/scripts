##########################################################################
############################ Preparing System ############################
##########################################################################

echo '>>>>>>>>> Configuring language variables ...'
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_COLLATE=C
export LC_CTYPE=en_US.UTF-8

echo '>>>>>>>>> Adding EPEL repository ...'
yum install -y epel-release

echo '>>>>>>>>> Updating the system package repository cache ...'
yum -y makecache

echo '>>>>>>>>> Updating the system’s packages ...'
yum -y update & yum -y upgrade

echo '>>>>>>>>> Installing the OpenSSH server package ...'
yum install -y openssh-server

echo '>>>>>>>>> Starting the OpenSSH service ...'
systemctl start sshd

echo '>>>>>>>>> Checking the status of the service ...'
systemctl status sshd

echo '>>>>>>>>> Enabling OpenSSH service ...'
systemctl enable sshd

echo '>>>>>>>>> Allowing the firewall for traffic flow through the SSH ...'
firewall-cmd --zone=public --permanent --add-service=ssh

echo '>>>>>>>>> Reloading the firewall after configuring ...'
firewall-cmd --reload

echo '>>>>>>>>> Restarting the machine ...'
reboot --force