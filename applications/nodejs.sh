#! /bin/bash

SUDO_PASS=$1
IP=$(hostname -I |  awk '{print $1}')

# LOADING LOG FUNCTIONS FILE
. ./_logs.sh
# LOADING FUNCTIONS FILE
. ./_functions.sh

_script_start "INSTALL NODEJS"
__verify_root_pass $SUDO_PASS
__detect_package_manager
__update_system $SUDO_PASS

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
fi
_step_result_success "✅ Node.js installed! Version: $(node --version)"
_step_result_success "✅ NVM installed! Version: $(nvm --version)"
_step_result_success "✅ NPM installed! Version: $(npm --version)"

echo -e "\n\n"

_step_result_success "🎉 Installation completed!"

_finish_information

_step "🔄 Rebooting the system ..."
echo $SUDO_PASS | sudo -S reboot