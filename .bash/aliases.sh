#! /bin/sh

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# enables grep color support
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias less='less -M'

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
if [ -d $repo_path ];then
	for i in $(ls $repo_path);do
		if [ -d $repo_path/$i ];then
			ni=$(echo $i | sed 's/\-/_/g')
			alias "R_$ni"="cd \"$repo_path$i\""
			declare "R_$ni"="$repo_path$i"
		fi
	done
fi

# get list of repos
code_path="$HOME/Documents/code/"
if [ -d $code_path ];then
	for i in $(ls $code_path);do
		if [ -d $code_path/$i ];then
			ni=$(echo $i | sed 's/\-/_/g')
			alias "C_$ni"="cd \"$code_path$i\""
			declare "C_$ni"="$code_path$i"
		fi
	done
fi

# program aliases
alias vi='vim'
alias mux='tmuxinator'

alias ssh-new-bash-session='eval `ssh-agent` && ssh-add'
alias ssh-new-session='keychain ~/.ssh/id_rsa && source ~/.keychain/$HOSTNAME-sh'

alias restart-plasmashell='killall plasmashell && kstart5 $_ &>/dev/null'

