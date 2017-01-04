#! /bin/sh

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more aliases
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
		ni=$(echo $i | sed 's/\-/_/g')
		alias "R_$ni"="cd \"$repo_path$i\""
		declare "R_$ni"="$repo_path$i"
	done
fi

# get list of repos
code_path="$HOME/Documents/code/"
if [ -d $code_path ];then
	for i in $(ls $code_path);do
		ni=$(echo $i | sed 's/\-/_/g')
		alias "C_$ni"="cd \"$code_path$i\""
		declare "C_$ni"="$code_path$i"
	done
fi

# program aliases
alias vi='vim'
alias python='python2'
alias pip='pip2'
alias ssh-new-session='eval `ssh-agent` && ssh-add'

