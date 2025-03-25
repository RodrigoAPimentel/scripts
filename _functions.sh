#! /bin/bash

# Loading log functions file
. ./_logs.sh

# Verifica se a senha do sudo foi informada
__verify_root_pass() {
    _step '🔍 Check if the sudo password was entered ...'
    if [ -z "${1}" ]; then
        _step_result_failed "❌ sudo password not entered!!"
        _step_result_suggestion "Sample: script.sh <sudo pass>"
        exit 1
    else
        _step_result_success "✅ sudo password entered."
    fi
}

# Verifica se o script está sendo executado como root
__verify_root() {
    _step '🔍 Checking if the script is being run as root ...'
    if [[ $EUID -ne 0 ]]; then
        _step_result_failed "❌ This script must be run as root."
        exit 1
    fi
    _step_result_success "✅ Script running as root."
}

# Detecta a distribuição do sistema
__detect_system() {
    _step "🔄 Detecting the system distribution ..."
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        _step_result_failed "❌ Unable to identify the operating system."
        exit 1
    fi
    _step_result_success "✅ System detected: $OS $VERSION"
}

# Detecta o gerenciador de pacotes
__detect_package_manager() {
    _step "🔄 Detecting the package manager ..."
    if command -v apt &> /dev/null; then
        local PKG_MANAGER=apt
    elif command -v dnf &> /dev/null; then
        local PKG_MANAGER=dnf
    else
        _step_result_failed "❌ Package manager not found."
        exit 1
    fi
    _step_result_success "✅ Package manager detected: $PKG_MANAGER"
    
    echo $PKG_MANAGER
}