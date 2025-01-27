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

___console_logs '[01/09] Truncate machine-id'
echo $SUDO_PASS | sudo -S truncate -s 0 /etc/machine-id
MACHINE_ID=$(cat /etc/machine-id)
echo "==> Machine ID: [$MACHINE_ID]"

___console_logs '[02/09] Install cloud-init and qemu-guest-agent'
echo $SUDO_PASS | sudo -S apt install -y cloud-init qemu-guest-agent

___console_logs '[03/09] Enable qemu-guest-agent'
echo $SUDO_PASS | sudo -S systemctl enable qemu-guest-agent

___console_logs '[04/09] Delete ssh key host'
echo $SUDO_PASS | sudo -S cd /etc/ssh && echo $SUDO_PASS | sudo -S rm ssh_host_*

___console_logs '[05/09] Purgue openssh-client'
echo $SUDO_PASS | sudo -S apt purge openssh-client -y

___console_logs '[06/09] Apt Clean'
echo $SUDO_PASS | sudo -S apt clean

___console_logs '[07/09] Cloud-init clean'
echo $SUDO_PASS | cloud-init clean

___console_logs '[08/09] Apt autoremove'
echo $SUDO_PASS | sudo -S apt autoremove -y

___console_logs '[09/09] Shutdown the machine'
echo $SUDO_PASS | sudo -S shutdown -h now

___console_logs '[09/09] Shutdown the machine'
echo "==> Add Cloudinit Drive. Here is an example: https://tcude.net/creating-a-vm-template-in-proxmox/"

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'