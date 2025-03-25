#! /bin/bash

. ./_logs.sh
. ./_functions.sh

SUDO_PASS=$1

_script_start "INITIAL PREPARATION"
__verify_root_pass $SUDO_PASS
__detect_package_manager
__update_system $SUDO_PASS
__install_prerequisite_packages $SUDO_PASS "curl tree apache2-utils golang-go cloud-init qemu-guest-agent yq gcc-c++ make python3.9"

./applications/nodejs.sh $SUDO_PASS

_step 'Enable qemu-guest-agent'
echo $SUDO_PASS | sudo -S systemctl enable qemu-guest-agent

_step 'Change time-zone settings'
echo $SUDO_PASS | sudo -S sudo timedatectl set-timezone America/Recife
date

_step 'Restarting the machine'
echo $SUDO_PASS | sudo -S reboot --force

_finish_information

_step "🔄 Rebooting the system ..."
echo $SUDO_PASS | sudo -S reboot