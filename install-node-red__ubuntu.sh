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

__detect_system

local PM=$(__detect_package_manager)

echo "=================== [$PM]"



# # Atualiza pacotes conforme a distribuição
# case "$OS" in
#     ubuntu|debian)
#         _step "📌 Atualizando pacotes no Debian/Ubuntu..."
#         apt update -y && apt upgrade -y
#         apt install -y curl gcc g++ make
#         ;;
#     centos|rocky|almalinux)
#         _step "📌 Atualizando pacotes no CentOS/Rocky/AlmaLinux..."
#         dnf update -y
#         dnf install -y curl gcc-c++ make
#         ;;
#     *)
#         _step_result_failed "❌ Sistema não suportado."
#         exit 1
#         ;;
# esac

# # Verifica se o Node.js já está instalado
# if command -v node &> /dev/null; then
#     _step_result_success "✅ Node.js já está instalado! Versão: $(node -v)"
# else
#     _step "⚠️ Node.js não encontrado. Instalando via NVM..."

#     # Baixa e instala o NVM
#     curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

#     # Carrega o NVM no ambiente atual
#     export NVM_DIR="$HOME/.nvm"
#     source "$NVM_DIR/nvm.sh"

#     # Instala a versão mais recente do Node.js LTS
#     nvm install --lts
#     nvm use --lts

#     _step_result_success "✅ Node.js instalado com NVM! Versão: $(node -v)"
# fi

# _step "🔍 Verificando versão do npm..."
# npm -v

# # Verifica se o PM2 já está instalado
# if command -v pm2 &> /dev/null; then
#     _step_result_success "✅ PM2 já está instalado! Versão: $(pm2 -v)"
# else
#     _step "⚠️ PM2 não encontrado. Instalando..."
#     npm install -g pm2
#     _step_result_success "✅ PM2 instalado! Versão: $(pm2 -v)"
# fi

# # Verifica se o Node-RED já está instalado
# if command -v node-red &> /dev/null; then
#     _step_result_success "✅ Node-RED já está instalado!"
# else
#     _step "⚠️ Node-RED não encontrado. Instalando..."
#     npm install -g --unsafe-perm node-red
#     _step_result_success "✅ Node-RED instalado!"
# fi

# # Verifica se o Node-RED já está rodando no PM2
# if pm2 list | grep -q "node-red"; then
#     _step_result_success "✅ Node-RED já está rodando no PM2!"
# else
#     _step "🔄 Iniciando Node-RED com PM2..."
#     pm2 start $(which node-red) -- -v
#     pm2 save
#     pm2 startup systemd | tee startup.txt
#     eval $(grep "sudo env" startup.txt)
#     _step_result_success "✅ Node-RED configurado para iniciar automaticamente!"
# fi

# _step_result_success "🎉 Instalação concluída!"
# _step_result_suggestion "🌐 Acesse o Node-RED em: http://$IP:1880"

# _finish_information