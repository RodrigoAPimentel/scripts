#! /bin/bash

. ./_logs.sh

SUDO_PASS=$1

_section "INSTALL PM2"

_step "🔍 Verifying PM2 Installation ..."
if command -v pm2 &> /dev/null; then
    _step_result_success "✅ PM2 is already installed! Version: $(pm2 -v)"
else
    echo "                 ⚠️ PM2 not found. Installing ..."
    
    if ! command -v npm &> /dev/null; then
        _step_result_failure "❌ NPM is required but not installed. Exiting script."
        exit 1
    fi

    npm install -g pm2
    
    if command -v pm2 &> /dev/null; then
        _step_result_success "✅ PM2 installed! Version: $(pm2 -v)"
    else
        _step_result_failure "❌ PM2 installation failed. Exiting script."
        exit 1
    fi
fi

echo -e "\n"

_step_result_success "✅ PM2 installed! Version: $(pm2 -v)"

echo -e "\n"

_step_result_success "🎉 Installation completed!"

_section_end