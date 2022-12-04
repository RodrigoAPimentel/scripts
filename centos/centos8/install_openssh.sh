##########################################################################
################ Enabling and configuring SSH on CentOS 8 ################
##########################################################################

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