#! /bin/bash

. ./_logs.sh
. ./_functions.sh

SUDO_PASS=$1

_script_start "INSTALL DOCKER AND DOCKER-COMPOSE"
__verify_root_pass $SUDO_PASS
__detect_package_manager
__update_system $SUDO_PASS
__install_prerequisite_packages $SUDO_PASS "apt-transport-https ca-certificates curl software-properties-common"

_step 'Add the GPG key for the official Docker repository'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

_step 'Add the Docker repository to APT sources'
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

__update_system $SUDO_PASS

_step 'Make sure you are about to install from the Docker repo instead of the default repo'
if [ "$package_manager" == "apt" ]; then
    apt-cache policy docker-ce
elif [ "$package_manager" == "yum" ]; then
    yum list docker-ce --showduplicates | sort -r
fi

_step 'Install Docker'
echo $SUDO_PASS | sudo -S $package_manager install -y docker-ce

_step 'Install Docker Compose'
echo $SUDO_PASS | sudo -S mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
echo $SUDO_PASS | sudo -S chmod +x ~/.docker/cli-plugins/docker-compose
_step_result_success "✅ Docker Compose Installed! Version: $(docker compose version)"

_step 'Add your username to the docker group'
echo $SUDO_PASS | sudo -S usermod -aG docker ${USER}

_step_result_success "🎉 Installation completed!"

_finish_information

_step "🔄 Rebooting the system ..."
echo $SUDO_PASS | sudo -S reboot --force