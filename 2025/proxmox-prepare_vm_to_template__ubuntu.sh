SUDO_PASS=$1

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 1
}

echo '##########################################################################'
echo '############### PROXMOX - PREPARE VM TO TEMPLATE [UBUNTU] ################'
echo '##########################################################################\n'

___console_logs '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    echo "XXX sudo password not entered!! XXX"
    echo "Sample: proxmox-prepare_vm_to_template__ubuntu.sh <sudo pass>"
    exit 1
else
    echo "==> sudo password entered."
fi

___console_logs '[01/07] Truncate machine-id'
echo $SUDO_PASS | sudo -S truncate -s 0 /etc/machine-id
cat /etc/machine-id

___console_logs '[02/07] Install cloud-init'
echo $SUDO_PASS | sudo -S apt install -y cloud-init

___console_logs '[03/07] Delete ssh key host'
echo $SUDO_PASS | sudo -S cd /etc/ssh && echo $SUDO_PASS | sudo -S rm ssh_host_*

___console_logs '[04/07] Purgue openssh-client'
echo $SUDO_PASS | sudo -S apt purge openssh-client -y

___console_logs '[05/07] Apt Clean'
echo $SUDO_PASS | sudo -S apt clean

___console_logs '[06/07] Apt autoremove'
echo $SUDO_PASS | sudo -S apt autoremove -y

___console_logs '[07/07] Poweroff the machine'
echo $SUDO_PASS | sudo -S poweroff

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'