SUDO_PASS=toor

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 1
}

echo '##########################################################################'
echo '############################ CONFIGURE UBUNTU ############################'
echo '##########################################################################\n'

___console_logs '[01/04] Update'
echo $SUDO_PASS | sudo -S sudo apt update

___console_logs '[02/04] Upgrade'
echo $SUDO_PASS | sudo -S sudo apt update -y

___console_logs '[03/04] Change time-xone settings'
echo $SUDO_PASS | sudo -S sudo timedatectl set-timezone America/Recife

___console_logs '[04/04] Restarting the machine'
echo $SUDO_PASS | sudo -S reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'