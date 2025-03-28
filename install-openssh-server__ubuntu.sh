SUDO_PASS=$1

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 1
}

echo '##########################################################################'
echo '################# INSTALL OPENSSH-SERVER IN UBUNTU 22.04 #################'
echo '##########################################################################\n'

___console_logs '[--] Check if the sudo password was entered'
if [ -z "${SUDO_PASS}" ]; then
    echo "XXX sudo password not entered!! XXX"
    echo "Sample: install-openssh-server__ubuntu.sh <SUDO PASS>"
    exit 1
else
    echo "==> sudo password entered."
fi

___console_logs '[01/04] Update packages'
echo $SUDO_PASS | sudo -S apt update

___console_logs '[02/04] Install openssh-server'
echo $SUDO_PASS | sudo -S apt install -y openssh-server

___console_logs '[03/04] Install openssh-server'
rm -v ~/install-openssh-server__ubuntu.sh

___console_logs '[04/04] Restarting the machine'
echo $SUDO_PASS | sudo -S reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'


