#17MAR2025
#! /bin/bash
rm ~/.bash_aliases
wget -P ~/ https://raw.githubusercontent.com/dlettiere/GeneralLinux/refs/heads/main/.bash_aliases
touch ~/.bash_aliases_local

###Base Packages to install
basepack="tmux btop htop nmap tilde qdirstat rdiff-backup rsync git vnstat tldr curl"

printf 'Install base components (y/n)? '
printf '$basepack'
old_stty_cfg=$(stty -g)
stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg # Careful playing with stty
if [ "$answer" != "${answer#[Yy]}" ];then
    sudo apt update
    #sudo apt install -y tmux btop htop nmap tilde qdirstat rdiff-backup rsync git vnstat tldr curl
else
    echo ok
fi

printf 'Install NordVPN (y/n)? '
old_stty_cfg=$(stty -g)
stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg # Careful playing with stty
if [ "$answer" != "${answer#[Yy]}" ];then
    curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh | sh
    sudo usermod -aG nordvpn $USER
else
    echo ok
fi

printf 'Install Tailscale (y/n)? '
old_stty_cfg=$(stty -g)
stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg # Careful playing with stty
if [ "$answer" != "${answer#[Yy]}" ];then
    curl -fsSL https://tailscale.com/install.sh | sh
else
    echo ok
fi

exit
