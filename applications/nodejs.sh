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
    echo $SUDO_PASS | sudo -S export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
    nvm install --lts
    nvm use --lts
fi

echo -e "\n"

NVM_VERSION=$(nvm --version)
_step_result_success "✅ Node.js installed! Version: $(node --version)"
_step_result_success "✅ NVM installed! Version: $NVM_VERSION"
_step_result_success "✅ NPM installed! Version: $(npm --version)"

echo -e "\n"

_step_result_success "🎉 Installation completed!"

_section_end