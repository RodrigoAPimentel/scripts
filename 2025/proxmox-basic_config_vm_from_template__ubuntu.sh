SUDO_PASS=$1
HOSTNAME=$2
IP=$3
GATEWAY=$4

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 1
}

echo '##########################################################################'
echo '########### PROXMOX - BASIC CONFIG VM FROM TEMPLATE [UBUNTU] #############'
echo '##########################################################################\n'

___console_logs '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    echo "XXX sudo password not entered!! XXX"
    echo "Sample: proxmox-basic_config_vm_from_template__ubuntu.sh <SUDO PASS> <HOSTNAME> <IP> <GATEWAY>"
    exit 1
else
    echo "==> sudo password entered."
fi
if [ -z "${HOSTNAME}" ]; then
    echo "XXX hostname not entered!! XXX"
    echo "Sample: proxmox-basic_config_vm_from_template__ubuntu.sh <SUDO PASS> <HOSTNAME> <IP> <GATEWAY>"
    exit 1
else
    echo "==> hostname entered."
fi
if [ -z "${IP}" ]; then
    echo "XXX IP not entered!! XXX"
    echo "Sample: proxmox-basic_config_vm_from_template__ubuntu.sh <SUDO PASS> <HOSTNAME> <IP> <GATEWAY>"
    exit 1
else
    echo "==> IP entered."
fi
if [ -z "${GATEWAY}" ]; then
    echo "XXX Gateway not entered!! XXX"
    echo "Sample: proxmox-basic_config_vm_from_template__ubuntu.sh <SUDO PASS> <HOSTNAME> <IP> <GATEWAY>"
    exit 1
else
    echo "==> Gateway entered."
fi

___console_logs '[01/05] Install openssh-server'
echo $SUDO_PASS | sudo -S apt install -y openssh-server

___console_logs "[02/05] Set Hostname [$HOSTNAME]"
echo $SUDO_PASS | sudo -S hostnamectl set-hostname $HOSTNAME

___console_logs "[03/05] Configure IP [$IP]"
sudo -i -u root bash << EOF2
echo $SUDO_PASS | sudo -S rm /etc/netplan/50-cloud-init.yaml
cat <<EOF > /etc/netplan/50-cloud-init.yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        ens18:
            addresses: [$IP/24]
            gateway4: $GATEWAY
            dhcp4: no
            nameservers:
              addresses: [1.1.1.1,8.8.8.8]
            optional: true
    version: 2
EOF
EOF2
echo $SUDO_PASS | sudo -S cat /etc/netplan/50-cloud-init.yaml
echo $SUDO_PASS | sudo -S netplan apply

___console_logs '[04/05] Configure Keyboard layout to ABNT2'
echo $SUDO_PASS | sudo -S sed -i "s|^XKBLAYOUT=.*|XKBLAYOUT=br|g" /etc/default/keyboard

___console_logs '[05/05] Restarting the machine'
echo $SUDO_PASS | sudo -S reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'


