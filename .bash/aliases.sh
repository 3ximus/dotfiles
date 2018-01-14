# Modeline {
#	 vi: tabstop=4 filetype=sh
# }

alias list-functions='select i in `grep -P "[a-zA-Z0-9_\-]+(?=\(\))" -o $HOME/.bash/functions.sh`; do declare -f $i; break; done'

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
fi

# enables grep color support
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias less='less -MR'

# more ls aliases
alias ll='ls -lF'
alias la='ls -AF'
alias lla='ls -lFA'
alias l.='ls -Fd .*'

alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'

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

unset i

# program aliases
alias vi='vim'
alias clipboard-in='xclip -in -selection clipboard'
alias clipboard-out='xclip -out -selection clipboard'
alias perl-regex='perl -p -i -e'

# SSH
alias ssh-new-bash-session='eval `ssh-agent` && ssh-add'
alias ssh-new-session='keychain ~/.ssh/id_rsa && source ~/.keychain/$HOSTNAME-sh'

# PLASMA
alias restart-plasmashell='killall plasmashell && kstart5 $_ &>/dev/null'
alias restart-tiling='qdbus org.kde.KWin /KWin reconfigure'
alias restart-kwin='kwin_x11 --replace &'

# wget to download directory, use -P to specify output directory
alias wget-directory='wget -r -np -nc -nd -k -nv'

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
