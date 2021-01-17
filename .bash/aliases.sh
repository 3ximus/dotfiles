# vi: tabstop=4

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
fi

alias list-functions='select i in `grep -P "[a-zA-Z0-9_\-]+(?=\(\))" -o $HOME/.bash/functions.sh`; do declare -f $i; break; done'

# more ls aliases
alias ll='ls -lF'
alias la='ls -AF'
alias lla='ls -lFA'
alias l.='ls -Fd .*'

alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'

alias dirs='dirs -v'

# Utilities
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias pacman='pacman --color=auto'
alias less='less -Mrix4'
alias gdb='gdb -q'
alias dd='dd status=progress'
alias alert="echo -ne '\a'"
alias perl-regex='perl -p -i -e'
alias grep-bin='grep -oUaP' # pattern like: "\xde\xad"
alias htop-mem='htop --sort-key=PERCENT_MEM'
alias htop-cpu='htop --sort-key=PERCENT_CPU'

# Clipboard
alias clipboard-in='xclip -in -selection clipboard'
alias ccopy='xclip -in -selection clipboard'
alias clipboard-out='xclip -out -selection clipboard'
alias cpaste='xclip -out -selection clipboard'

# mount ntfs filesystems with correct permissions
alias mount-ntfs='sudo mount -o uid=1000,gid=1000,dmask=027,fmask=137'

# git, the quoting hack is needed to use nested single quotes
alias git-lfs='git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -10 | awk '"'"'{print$1}'"'"')"'
alias gs='git status'
alias gp='git push'
alias gc='git commit'
alias ga='git add .'
alias gl='git lol | less' # because my own alias is too much typing
alias gd='git diff'

# python3 alias
# alias python='python3'
# alias ipython='ipython3'

# pacman / aur
alias aur-packages='pacman -Qm'
alias list-packages='expac -H M "%m\t%-30n" | sort -rh | less'
alias paccache-clean='paccache -rk1 && paccache -ruk0'

# SSH
alias load-keychain='[[ -f "${HOME}/.ssh/id_rsa" ]] && keychain "${HOME}/.ssh/id_rsa" --quiet && source "${HOME}/.keychain/${HOSTNAME}-sh"'

# PLASMA
alias restart-plasmashell='killall plasmashell && kstart5 $_ &>/dev/null'
alias restart-tiling='qdbus org.kde.KWin /KWin reconfigure'
alias restart-kwin='kwin_x11 --replace &'

# attach/kill tmux sessions
alias tmux-attach-session='tmux list-sessions; read -r -p "Attach to > " REPLY; tmux attach-session -t $REPLY'
alias tmux-kill-session='tmux list-sessions; read -r -p "Kill session > " REPLY; tmux kill-session -t $REPLY'

# i keep forgetting this...
alias man-pipes='echo "Generic form #>/dev/null (# is 1 by default)"; echo "  2>&-        ----> #>&-  (close fd)"; echo "  |&          ----> 2>&1"; echo "  &>/dev/null ----> 1>/dev/null 2>&1"'

# wget to download directory, use -P to specify output directory
# -k option might give memory issues when continuing (-c) the download of large files but without it wget wont check for partially downlaoded files and will assume they are downloaded if they exist
alias wget-directory='wget -r -np -nc -nd -k'

alias pip-upgrade='pip3 list --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 sudo pip3 install -U'

# PLEX
# Add this to sudoers or a file in sudoers.d
#      %eximus ALL= NOPASSWD: /bin/systemctl start plexmediaserver.service
#      %eximus ALL= NOPASSWD: /bin/systemctl stop plexmediaserver.service
#      %eximus ALL= NOPASSWD: /bin/systemctl restart plexmediaserver.service
alias plex='sudo systemctl start plexmediaserver.service'
alias plex-status='systemctl status plexmediaserver.service'
alias plex-stop='sudo systemctl stop plexmediaserver.service'
alias plex-restart='sudo systemctl restart plexmediaserver.service'

