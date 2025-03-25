#! /bin/bash

SUDO_PASS=$1
IP=$(hostname -I |  awk '{print $1}')

# LOADING LOG FUNCTIONS FILE
. ./_logs.sh
# LOADING FUNCTIONS FILE
. ./_functions.sh

_script_start "INSTALL NODE-RED"
__verify_root_pass $SUDO_PASS
__verify_root
__detect_package_manager
__update_system $SUDO_PASS
__install_basic_packages $SUDO_PASS "curl gcc g++ make"

# Check if Node.js is already installed
_step "🔍 Verifying Node.js Installation ..."
if command -v node &> /dev/null; then
    _step_result_success "✅ Node.js is already installed! Version: $(node -v)"
else
    echo "                 ⚠️ Node.js not found. Installing via NVM..."
    echo $SUDO_PASS | sudo -S curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    _step_result_success "✅ Node.js installed with NVM! Version: $(node -v)"
fi

_step "🔍 Verifying npm version..."
NPM_VERSION=$(npm -v)
_step_result_success "✅ npm version: $NPM_VERSION"

# Check if PM2 is already installed
_step "🔍 Verifying PM2 Installation ..."
if command -v pm2 &> /dev/null; then
    _step_result_success "✅ PM2 is already installed! Version: $(pm2 -v)"
else
    echo "                  ⚠️ PM2 not found. Installing..."
    npm install -g pm2
    if command -v pm2 &> /dev/null; then
        _step_result_success "✅ PM2 installed! Version: $(pm2 -v)"
    else
        _step_result_failure "❌ PM2 installation failed. Exiting script."
        exit 1
    fi
fi

# Check if Node-RED is already installed
_step "🔍 Verifying Node-RED Installation ..."
if command -v node-red &> /dev/null; then
    _step_result_success "✅ Node-RED is already installed!"
else
    echo "                  ⚠️ Node-RED not found. Installing..."
    npm install -g --unsafe-perm node-red
    _step_result_success "✅ Node-RED installed!"
fi

# Check if Node-RED is already running on PM2
_step "🔍 Verifying Node-RED on PM2..."
if pm2 list | grep -q "node-red"; then
    _step_result_success "✅ Node-RED is already running on PM2!"
else
    echo "                  🔄 Starting Node-RED with PM2..."
    pm2 start node-red -- -v
    pm2 save
    mkdir -p /opt/pm2
    pm2 startup systemd | tee /opt/pm2/pm2-startup.sh
    chmod +x /opt/pm2/pm2-startup.sh
    echo $SUDO_PASS | sudo -S ./opt/pm2/pm2-startup.sh
    
    _step_result_success "✅ Node-RED configured to start automatically!"
fi

echo -e "\n\n\n"

_step_result_success "🎉 Installation completed!"
_step_result_suggestion "🌐 Access Node-RED at: http://$IP:1880"

_finish_information