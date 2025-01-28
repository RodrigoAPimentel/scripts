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

___console_logs '[01/12] Truncate machine-id'
echo $SUDO_PASS | sudo -S truncate -s 0 /etc/machine-id

___console_logs '[02/12] Install cloud-init and qemu-guest-agent'
echo $SUDO_PASS | sudo -S apt install -y cloud-init qemu-guest-agent

___console_logs '[03/12] Enable qemu-guest-agent'
echo $SUDO_PASS | sudo -S systemctl enable qemu-guest-agent

___console_logs '[04/12] Delete ssh key host'
echo $SUDO_PASS | sudo -S rm -v /etc/ssh/ssh_host_*

___console_logs '[05/12] Purgue openssh-client'
echo $SUDO_PASS | sudo -S apt purge openssh-client -y

___console_logs '[06/12] Apt Clean'
echo $SUDO_PASS | sudo -S apt clean

___console_logs '[07/12] Cloud-init clean'
echo $SUDO_PASS | sudo -S cloud-init clean

___console_logs '[08/12] Apt autoremove'
echo $SUDO_PASS | sudo -S apt autoremove -y

___console_logs '[09/12] Copy install-openssh-server__ubuntu.sh to ~/'
cp ~/scripts/2025/install-openssh-server__ubuntu.sh ~/install_openssh-server

___console_logs '[10/12] Delete scripts folder'
rm -rvf ~/scripts

___console_logs '[11/12] Add Cloudinit Drive Hardware'
echo "==> Add Cloudinit Drive Hardware. Here is an example: https://tcude.net/creating-a-vm-template-in-proxmox/"

___console_logs '[12/12] Shutdown the machine'
echo $SUDO_PASS | sudo -S shutdown -h now

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'