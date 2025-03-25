#! /bin/bash

. ./_logs.sh
. ./_functions.sh

SUDO_PASS=$1
IP=$(hostname -I |  awk '{print $1}')

_script_start "INSTALL NODE-RED"
__verify_root_pass $SUDO_PASS
__detect_package_manager
__update_system $SUDO_PASS
__install_prerequisite_packages $SUDO_PASS "curl gcc g++ make"
./applications/nodejs.sh $SUDO_PASS
./applications/pm2.sh $SUDO_PASS

_step "🔍 Verifying Node-RED Installation ..."
if command -v node-red &> /dev/null; then
    _step_result_success "✅ Node-RED is already installed!"
else
    echo "                  ⚠️ Node-RED not found. Installing..."
    npm install -g --unsafe-perm node-red
    _step_result_success "✅ Node-RED installed!"
fi

_step "🔍 Verifying Node-RED on PM2..."
if pm2 list | grep -q "node-red"; then
    _step_result_success "✅ Node-RED is already running on PM2!"
else
    _step "🔄 Starting Node-RED with PM2 ..."
    pm2 start node-red -- -v
    _step "🔄 Save Node-RED with PM2 ..."
    pm2 save
    _step "🔄 Configure PM2 resurrect ..."
    echo $SUDO_PASS | sudo -S mkdir -p /opt/pm2
    pm2 startup systemd | echo $SUDO_PASS | sudo -S tee /opt/pm2/pm2-startup.sh
    echo $SUDO_PASS | sudo -S chmod +x /opt/pm2/pm2-startup.sh
    echo $SUDO_PASS | sudo -S /opt/pm2/pm2-startup.sh
    
    _step_result_success "✅ Node-RED configured to start automatically!"
fi

echo -e "\n\n"

_step_result_success "🎉 Installation completed!"
_step_result_suggestion "🌐 Access Node-RED at: http://$IP:1880"

_finish_information

_step "🔄 Rebooting the system ..."
echo $SUDO_PASS | sudo -S reboot