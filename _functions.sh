#! /bin/bash

# Loading log functions file
. ./_logs.sh

# Carrega o arquivo de pacotes básicos
. ./_basic_packages.sh

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
    _step "🔍 Detecting the system distribution ..."
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        _step_result_failed "❌ Unable to identify the operating system."
        exit 1
    fi
    _step_result_success "✅ System detected: $OS $VERSION"

    export OS=$OS
    export VERSION=$VERSION
    return
}

# Detecta o gerenciador de pacotes
__detect_package_manager() {
    __detect_system

    _step "🔍 Detecting the package manager ..."
    if command -v apt &> /dev/null; then
        local PKG_MANAGER=apt
    elif command -v dnf &> /dev/null; then
        local PKG_MANAGER=dnf
    else
        _step_result_failed "❌ Package manager not found."
        exit 1
    fi
    _step_result_success "✅ Package manager detected: $PKG_MANAGER"
    
    export package_manager=$PKG_MANAGER
    return
}

# Atualiza o sistema
__update_system() {
    _step "🔄 Updating packages list on $OS $VERSION ..."
    echo $1 | sudo -S $package_manager update -y
    _step "🔄 Upgrade packages on $OS $VERSION ..."
    echo $1 | sudo -S $package_manager upgrade -y
    _step "🔄 Dist Upgrade on $OS $VERSION ..."
    echo $1 | sudo -S $package_manager dist-upgrade -y
}

# Instala pacotes básicos
__install_prerequisite_packages() {
    local packages=${2:-$BASIC_PACKAGES}
    _step "📦 Installing prerequisite packages [$packages] ..."
    for package in $packages; do
        echo $1 | sudo -S $package_manager install -y $package || _step_result_failed "⚠️ Failed to install $package. Continuing with the next package..."
    done

    if [ "$OS" != "centos" ]; then
        _step "🔍 Verifying installed packages ..."
        for package in $packages; do
            if dpkg -l | grep -q "^ii  $package "; then
                _step_result_success "✅ $package is installed."
            else
                _step_result_failed "❌ $package is not installed."
            fi
        done
    else
        _step_result_suggestion "⚠️ Package verification is not supported on CentOS."
    fi
}

__verify_packages_installed() {
    _step "🔍 Verifying $1 Installation ..."
    if command -v $1 &> /dev/null; then
        _step_result_success "✅ $1 is already installed!"
    else
        _step_result_failed "❌ $1 not installed."
        _step "Finishing the script ..."
        exit 1
    fi
}