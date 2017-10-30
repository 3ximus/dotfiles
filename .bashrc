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

# enable extended pattern matching features
# see http://wiki.bash-hackers.org/syntax/pattern
shopt -s extglob

# a command name that is the name of a directory is executed
# as if it were the argument to the cd command.
shopt -s autocd

# minor errors in the spelling of a directory component in a cd command
# will be corrected. The errors checked for are transposed characters,
# a missing character, and one character too many. If a correction is found,
# the corrected file name is printed, and the command proceeds.
shopt -s cdspell

# expands bang combinations and variables to their values - remember !$ last arg / !^ first arg / !* all args
bind Space:magic-space	# also combine these with :h (head) or :t (tail) to get path selective path expansion -> !$:h

# set a fancy prompt
case "$TERM" in
	xterm-color) color_prompt=yes;;
esac

# enable programmable completion features
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

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
	if [ -f ~/.bash/prompts/prompt_6.sh ]; then
		source ~/.bash/prompts/prompt_6.sh
	fi
else
	PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Source all files inside ./bash (only files)
for file in ~/.bash/* ; do
	[[ -f $file ]] && source $file
done

# source keychain file if it exists
if [ -f ~/.keychain/$HOSTNAME-sh ]; then
	source ~/.keychain/$HOSTNAME-sh
fi

# Print logo when exiting
# print_on_exit () { printf "$(cat ~/.banner)"; sleep 0.3; }
# trap print_on_exit EXIT

# konsole background blur
if [[ $UID != 0 && -z $SSH_CLIENT ]]; then
	if hash qdbus 2>/dev/null && qdbus &>/dev/null; then
		konsolex=$(qdbus | grep konsole | cut -f 2 -d\ )
		if [ -n konsolex ]; then
			for konsole in $konsolex; do
				xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id \
					`qdbus $konsole /konsole/MainWindow_1 winId`;
			done
		fi
	fi
fi

#export LS_COLORS="$LS_COLORS:*.c=1;36:*.h=00;36"
export MYSQL_PS1="\u - \d > "
export EDITOR="vim"
# add customs scripts and gem installed packages
export PATH=$HOME/.bash/scripts:$PATH

