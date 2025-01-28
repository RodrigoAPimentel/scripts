___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 2
}

pm=$(./_identify_package_manager.sh)

echo '##########################################################################'
echo '###################### INITIAL MACHINE PREPARATION #######################'
echo '##########################################################################\n'

___console_logs 'Setting language variables'
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_COLLATE=C
export LC_CTYPE=en_US.UTF-8

___console_logs 'Adding EPEL repository'
$pm install -y epel-release

___console_logs 'Updating the system package repository cache'
$pm -y makecache

___console_logs 'Updating the system’s packages'
$pm -y update & $pm -y upgrade

___console_logs 'Installing the OpenSSH server package'
$pm install -y openssh-server

___console_logs 'Starting the OpenSSH service'
systemctl start sshd

___console_logs 'Enabling OpenSSH service'
systemctl enable sshd

___console_logs 'Allowing the firewall for traffic flow through the SSH'
firewall-cmd --zone=public --permanent --add-service=ssh

___console_logs 'Reloading the firewall after configuring'
firewall-cmd --reload

___console_logs 'Restarting the machine'
reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'