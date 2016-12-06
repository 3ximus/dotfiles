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
	if [ -f ~/.bash/prompt_2 ]; then
		source ~/.bash/prompt_2
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

# Alias definitions. If available try to load them from a .bash_aliases file.
if [ -f ~/.bash/bash_aliases ]; then
    . ~/.bash/bash_aliases
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

# Function definitions. If available try to load them from a .bash_functions file.
if [ -f ~/.bash/bash_functions ]; then
    . ~/.bash/bash_functions
fi

export PATH=$PATH:$HOME/.gem/ruby/2.3.0/bin
