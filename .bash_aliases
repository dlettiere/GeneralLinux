#DanAliases
alias ls='ls -al'
alias la='ls -A'
alias l='ls -CF'

alias edital='sudo nano ~/.bash_aliases'
alias apt='sudo apt'
alias reboot='sudo reboot'
alias dockervol='cd /var/lib/docker/volumes'
alias uppy='apt update && apt upgrade -y && apt autoremove && apt autoclean'
alias r='. ~/.bashrc'
#alias size='du -sh'
#alias count='tree -a | tail -1'
#alias stats='echo size && echo count'
alias install='apt install'
alias 2tb='cd /media/2tbpassport'
alias 5tb='cd /media/5tb'

alias ra='cd /raidarray'
alias ram='cd /raidarray/media'
alias raf='cd /raidarray/fileserve'
alias dl='cd /home/pi/downloads'
alias dk='cd /home/pi/docker'

alias dockup='docker compose up -d'
alias dockdown='docker compose down'
#alias stats='OUT=$(find . -type f -name '*.*' -exec du -ch {} +) | N=$(echo "$OUT" | head -n -1 | wc -l) | SIZE=$(echo "$OUT" | tail -n 1) | echo "Number of files: $N" | echo $SIZE'

function stats() {
OUT=$(find . -type f -name '*.*' -exec du -ch {} +)
N=$(echo "$OUT" | head -n -1 | wc -l)
SIZE=$(echo "$OUT" | tail -n 1)
echo "Number of files: $N"
echo $SIZE
}

#function hello() {
#   echo find . -type f -name '*.*' -exec du -ch {} +
#}

#export -f hello
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
