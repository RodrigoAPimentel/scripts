#! /bin/bash

. ./_logs.sh

SUDO_PASS=$1

_section "INSTALL NODEJS"

_step "🔍 Verifying Node.js Installation ..."
if command -v node &> /dev/null; then
    _step_result_success "✅ Node.js is already installed! Version: $(node -v)"
else
    echo "                 ⚠️ Node.js not found. Installing via NVM ..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
fi

echo -e "\n"

_step_result_success "✅ Node.js installed! Version: $(node --version)"
_step_result_success "✅ NVM installed! Version: $(nvm --version)"
_step_result_success "✅ NPM installed! Version: $(npm --version)"

echo -e "\n"

_step_result_success "🎉 Installation completed!"

_section_end