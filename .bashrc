# ~/.bashrc: executed by bash for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# set edit mode
set -o emacs

# don't put duplite lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# set history length)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set a fancy prompt
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# Colored promp
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
	# load default bash_prompt
	if [ -f ~/.bash/prompt_4 ]; then
		source ~/.bash/prompt_4
	fi
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# MYSQL prompt
export MYSQL_PS1="\u - \d > "

# load git prompt
if [ -f ~/.bash/git-prompt.sh ]; then
	source ~/.bash/git-prompt.sh
fi

# Print logo when exiting
# print_on_exit () { printf "$(cat ~/.banner)"; sleep 0.3; }
# trap print_on_exit EXIT

# Alias definitions. If available try to load them from a aliases file.
if [ -f ~/.bash/aliases.sh ]; then
    . ~/.bash/aliases.sh
fi

# expands bang combinations and variables to their values - remember !$ last arg / !^ first arg / !* all args
bind Space:magic-space	# also combine these with :h (head) or :t (tail) to get path selective path expansion -> !$:h

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# add more colors filetypes printed with ls command
#export LS_COLORS="$LS_COLORS:*.c=1;36:*.h=00;36"

# Function definitions. If available try to load them from a functions file.
if [ -f ~/.bash/functions.sh ]; then
    . ~/.bash/functions.sh
fi

# konsole background blur
konsolex=$(qdbus | grep konsole | cut -f 2 -d\ )
if [ -n konsolex ]; then
	for konsole in $konsolex; do
		xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id `qdbus $konsole /konsole/MainWindow_1 winId`;
	done
fi

export PATH=$PATH:$HOME/.gem/ruby/2.3.0/bin
