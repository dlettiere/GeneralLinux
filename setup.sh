#! /bin/bash
rm ~/.bash_aliases
wget -P ~/ https://raw.githubusercontent.com/dlettiere/GeneralLinux/refs/heads/main/.bash_aliases
sudo apt update
sudo apt install tmux btop htop nmap tilde qdirstat rdiff-backup openssh rsync git
exit
