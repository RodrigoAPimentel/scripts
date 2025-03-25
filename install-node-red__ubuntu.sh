#! /bin/bash

SUDO_PASS=$1

IP=$(hostname -I |  awk '{print $1}')

BASIC_PACKAGES="curl gcc g++ make"

# LOADING LOG FUNCTIONS FILE
. ./_logs.sh
# LOADING FUNCTIONS FILE
. ./_functions.sh

_script_start "INSTALL NODE-RED"
__verify_root_pass $SUDO_PASS
__verify_root
__detect_system
__detect_package_manager
__update_system $SUDO_PASS
__install_basic_packages $SUDO_PASS

# Check if Node.js is already installed
_step "🔍 Verifying Node.js Installation ..."
if command -v node &> /dev/null; then
    _step_result_success "✅ Node.js is already installed! Version: $(node -v)"
else
    _step "⚠️ Node.js not found. Installing via NVM..."

    # Download and install NVM
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

    # Load NVM into the current environment
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"

    # Install the latest Node.js LTS version
    nvm install --lts
    nvm use --lts

    _step_result_success "✅ Node.js installed with NVM! Version: $(node -v)"
fi

_step "🔍 Verifying npm version..."
NPM_VERSION=$(npm -v)
_step_result_success "✅ npm version: $NPM_VERSION"

# # Check if PM2 is already installed
# if command -v pm2 &> /dev/null; then
#     _step_result_success "✅ PM2 is already installed! Version: $(pm2 -v)"
# else
#     _step "⚠️ PM2 not found. Installing..."
#     npm install -g pm2
#     _step_result_success "✅ PM2 installed! Version: $(pm2 -v)"
# fi

# # Check if Node-RED is already installed
# if command -v node-red &> /dev/null; then
#     _step_result_success "✅ Node-RED is already installed!"
# else
#     _step "⚠️ Node-RED not found. Installing..."
#     npm install -g --unsafe-perm node-red
#     _step_result_success "✅ Node-RED installed!"
# fi

# # Check if Node-RED is already running on PM2
# if pm2 list | grep -q "node-red"; then
#     _step_result_success "✅ Node-RED is already running on PM2!"
# else
#     _step "🔄 Starting Node-RED with PM2..."
#     pm2 start $(which node-red) -- -v
#     pm2 save
#     pm2 startup systemd | tee startup.txt
#     eval $(grep "sudo env" startup.txt)
#     _step_result_success "✅ Node-RED configured to start automatically!"
# fi

# _step_result_success "🎉 Installation completed!"
# _step_result_suggestion "🌐 Access Node-RED at: http://$IP:1880"

# _finish_information