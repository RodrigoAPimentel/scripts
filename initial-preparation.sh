#! /bin/bash

SUDO_PASS=$1

# LOADING LOG FUNCTIONS FILE
. ./_logs.sh
# LOADING FUNCTIONS FILE
. ./_functions.sh

_script_start "INITIAL PREPARATION"
# __verify_root_pass $SUDO_PASS
# __detect_package_manager
# __update_system $SUDO_PASS
# __install_basic_packages $SUDO_PASS "curl tree apache2-utils golang-go cloud-init qemu-guest-agent yq gcc-c++ make python3.9"

./applications/nodejs.sh $SUDO_PASS




# curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
# echo $SUDO_PASS | sudo -S export NVM_DIR="$HOME/.nvm"
# echo $SUDO_PASS | sudo -S source "$NVM_DIR/nvm.sh"
# nvm install --lts
# nvm use --lts

# ___console_logs '[03/10] Enable qemu-guest-agent'
# echo $SUDO_PASS | sudo -S systemctl enable qemu-guest-agent

# ___console_logs '[04/05] Change time-zone settings'
# echo $SUDO_PASS | sudo -S sudo timedatectl set-timezone America/Recife
# date

# ___console_logs '[05/05] Restarting the machine'
# echo $SUDO_PASS | sudo -S reboot --force

# echo " " 
# echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
# echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
# echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'


# _step "🔄 Rebooting the system ..."
# echo $SUDO_PASS | sudo -S reboot