#DanAliases 08MAR2025
alias ls='ls -alh'
alias la='ls -Ah'
alias l='ls -CFh'

alias edital='sudo nano ~/.bash_aliases'
alias ba='edital'
alias r='. ~/.bashrc'

alias apt='sudo apt'
alias install='apt install -y'
alias reboot='sudo reboot'
alias uppy='apt update && apt upgrade -y && apt autoremove -y && apt autoclean -y'

alias dockup='docker compose up -d'
alias dockdown='docker compose down'

function stats() {
OUT=$(find . -type f -name '*.*' -exec du -ch {} +)
N=$(echo "$OUT" | head -n -1 | wc -l)
SIZE=$(echo "$OUT" | tail -n 1)
echo "Number of files: $N"
echo $SIZE
}
export -f stats

alias rcopy='rsync -a --info=progress2 --no-i-r'
alias rcopydry='rsync -a -n --info=progress2 --no--r-r'
alias rmove='sudo rsync -a --info=progress2 --no-i-r --remove-source-files'

alias ta='tmux a'
alias dush='du -sh'
alias dockedit='sudo nano docker-compose.yml'
alias dc='dockedit'
alias rf='rm -rf'
alias nfowipe='find . -name "*.nfo" -type f -delete'
alias txtwipe='find . -name "*.txt" -type f -delete'

killZombie() {
    pid=$(ps -A -ostat,ppid | awk '/[zZ]/ && !a[$2]++ {print $2}');
    if [ "$pid" = "" ]; then
        echo "No zombie processes found.";
    else
        cmd=$(ps -p $pid -o cmd | sed '1d');
        echo "Found zombie process PID: $pid";
        echo "$cmd";
        echo "Kill it? Return to continue… (ctrl+c to cancel)";
        read -r;
        sudo kill -9 $pid;
    fi
}

mktar(){
tar -czvf "$1".tar.gz "$1"
}
