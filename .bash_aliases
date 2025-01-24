#DanAliases
alias ls='ls -al'
alias la='ls -A'
alias l='ls -CF'

alias edital='sudo nano ~/.bash_aliases'
alias r='. ~/.bashrc'

alias apt='sudo apt'
alias install='apt install'
alias reboot='sudo reboot'
alias uppy='apt update && apt upgrade -y && apt autoremove && apt autoclean'

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
