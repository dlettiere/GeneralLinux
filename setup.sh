#08MAR2025
#! /bin/bash
rm ~/.bash_aliases
wget -P ~/ https://raw.githubusercontent.com/dlettiere/GeneralLinux/refs/heads/main/.bash_aliases
sudo apt update
sudo apt install -y tmux btop htop nmap tilde qdirstat rdiff-backup rsync git
curl -fsSL https://tailscale.com/install.sh | sh
curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh | sh
sudo usermod -aG nordvpn $USER
exit
