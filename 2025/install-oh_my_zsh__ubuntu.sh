SUDO_PASS=toor

___console_logs () {
    echo " "
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    echo ">>>>>>>>> $1 ..."
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    sleep 1
}

echo '##########################################################################'
echo '############################ INSTALL OH-MY-ZSH ###########################'
echo '##########################################################################\n'

___console_logs '[02/11] Install a few prerequisite packages'
echo $SUDO_PASS | sudo -S apt install -y zsh golang-go fontconfig

___console_logs '[02/11] Download oh-my-zsh'
echo $SUDO_PASS | sudo -S rm -r $HOME/.oh-my-zsh

echo $SUDO_PASS | sudo -S rm -Rf /root/.oh-my-zsh
echo $SUDO_PASS | sudo -S rm -Rf ~/.zshrc
echo $SUDO_PASS | sudo -S chsh -s /bin/zsh root
echo $SUDO_PASS | sudo -S echo $SHELL

___console_logs '[02/11] Install oh-my-zsh'
echo $SUDO_PASS | sudo -S wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
echo $SUDO_PASS | sudo -S /bin/cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

___console_logs '[02/11] Downloading, Install and configuring plugins plugins'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/supercrabtree/k ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions && autoload -U compinit && compinit
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && sed -i '/ask ".*/s/^/#/g' ~/.fzf/install && ~/.fzf/install
sed -i "s|^plugins=(git)|plugins=(git zsh-syntax-highlighting fzf zsh-autosuggestions k zsh-completions)|g" ~/.zshrc

___console_logs '[02/11] Downloading and Install Powerline Fonts'
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

___console_logs '[02/11] Download and Install PowerLevel10K Theme'
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

___console_logs '[02/11] Configuring Theme'
sed -i 's|^ZSH_THEME=.*|ZSH_THEME="af-magic"|g' ~/.zshrc
# sed -i 's|^ZSH_THEME=.*|ZSH_THEME="jonathan"|g' ~/.zshrc
# sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|g' ~/.zshrc

___console_logs '[02/11] Copy Powerlevel10k configuration file'
rm -rfv ~/.p10k.zsh 
cp -rv 2025/resources/p10k_zsh_plugin_configuration.txt ~/.p10k.zsh

chmod 0644 ~/.p10k.zsh 

echo $SUDO_PASS | sudo -S chown root ~/.p10k.zsh 
echo $SUDO_PASS | sudo -S chgrp root ~/.p10k.zsh 

___console_logs '[02/11] Configuring Powerlevel10k in .zshrc'
echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> ~/.zshrc 


___console_logs '[11/11] Reload Terminal'
echo $SUDO_PASS | sudo -S chsh -s $(which zsh)
zsh --login

# ___console_logs '[11/11] Restarting the machine'
# echo $SUDO_PASS | sudo -S reboot --force

echo " " 
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<< END <<<<<<<<<<<<<<<<<<<<<<<<<'
echo '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'