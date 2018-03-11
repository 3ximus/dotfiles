# Modeline {
#	 vi: tabstop=4 filetype=sh
# }

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

# Utilities
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias less='less -MR'
alias vi='vim'
alias gdb='gdb -q'
alias dd='dd status=progress'
alias alert="echo -ne '\a'"
alias clipboard-in='xclip -in -selection clipboard'
alias clipboard-out='xclip -out -selection clipboard'
alias perl-regex='perl -p -i -e'
alias grep-bin='grep -obUaP' # pattern like: "\xde\xad"
alias htop-mem='htop --sort-key=PERCENT_MEM'
alias htop-cpu='htop --sort-key=PERCENT_CPU'

# mount ntfs filesystems with correct permissions
alias mount-ntfs='sudo mount -o uid=1000,gid=1000,dmask=027,fmask=137'

# pacman / aur
alias aur-packages='pacman -Qm'
alias list-packages='expac -H M "%m\t%n" | sort -h'

# transmission
alias transmissiond-start='transmission-daemon -g ~eximus/.config/transmission/'

# Virtualenv
alias activate='source $(find . -regex .*activate$)'

# SSH
alias ssh-new-bash-session='eval `ssh-agent` && ssh-add'
alias ssh-new-session='keychain ~/.ssh/id_rsa && source ~/.keychain/$HOSTNAME-sh'

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

alias pip-upgrade='pip list --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 sudo pip install -U'

# PLEX
# Add this to sudoers or a file in sudoers.d
#      %eximus ALL= NOPASSWD: /bin/systemctl start plexmediaserver.service
#      %eximus ALL= NOPASSWD: /bin/systemctl stop plexmediaserver.service
#      %eximus ALL= NOPASSWD: /bin/systemctl restart plexmediaserver.service
alias plex='sudo systemctl start plexmediaserver.service'
alias plex-status='systemctl status plexmediaserver.service'
alias plex-stop='sudo systemctl stop plexmediaserver.service'
alias plex-restart='sudo systemctl restart plexmediaserver.service'

alias crypto-cap='coinmon -c eur -t $(($LINES / 2 - 2))'

# PATH ALIASES

# get list of repos
repo_path="$HOME/Documents/rep/"
if [ -d "$repo_path" ];then
	for i in $(ls $repo_path);do
		if [ -d "$repo_path/$i" ];then
			ni=$(echo $i | sed 's/\-/_/g')
			alias "R_$ni"="cd \"$repo_path$i\""
			declare "R_$ni"="$repo_path$i"
		fi
	done
fi
alias R_="cd $repo_path"

# get list of code directories
code_path="$HOME/Documents/code/"
if [ -d "$code_path" ];then
	for i in $(ls $code_path);do
		if [ -d "$code_path/$i" ];then
			ni=$(echo $i | sed 's/\-/_/g')
			alias "C_$ni"="cd \"$code_path$i\""
			declare "C_$ni"="$code_path$i"
		fi
	done
fi

unset i ni

