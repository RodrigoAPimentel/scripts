SUDO_PASS=$1

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

___console_logs '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    echo "XXX sudo password not entered!! XXX"
    echo "Sample: initial-preparation__ubuntu.sh <sudo pass>"
    exit 1
else
    echo "==> sudo password entered."
fi

___console_logs '[01/04] Install basic applications'
echo $SUDO_PASS | sudo -S apt install -y curl tree apache2-utils

___console_logs '[02/04] Update and Upgrade System'
echo $SUDO_PASS | sudo -S apt update && echo $SUDO_PASS | sudo -S apt upgrade -y

___console_logs '[03/04] Change time-zone settings'
echo $SUDO_PASS | sudo -S sudo timedatectl set-timezone America/Recife
date

___console_logs '[04/04] Restarting the machine'
echo $SUDO_PASS | sudo -S reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
