# ~/.bashrc: executed by bash for non-login shells.

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

[[ $- == *i* ]] && source $HOME/.bash/ble.sh/out/ble.sh --noattach --rcfile $HOME/.bash/blerc

# ===============
#    SETTINGS
# ===============

# set edit mode
set -o emacs

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable extended pattern matching features
# see http://wiki.bash-hackers.org/syntax/pattern
shopt -s extglob

# turn on recursive globbing (enables ** to recurse all directories)
shopt -s globstar 2>/dev/null

# a command name that is the name of a directory is executed
# as if it were the argument to the cd command.
shopt -s autocd

# perform word expansion when trying filename completion
# useful when trying to type path with variable on it
shopt -s direxpand

# minor errors in the spelling of a directory component in a cd command
# will be corrected. The errors checked for are transposed characters,
# a missing character, and one character too many. If a correction is found,
# the corrected file name is printed, and the command proceeds.
shopt -s cdspell 2>/dev/null

# expands bang combinations and variables to their values
# SEE man bash / HISTORY EXPANSION  for a full list of bang features
bind Space:magic-space	#

# disable Ctrl-S ( flow control )
stty -ixon

# turn off feature to send focus gain or focus lost commands ^[[O ^[[I
printf "\e[?1004l"

# ===============
# HISTORY CONTROL
# ===============

# don't save duplicates
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# set history length)
HISTSIZE=20000
HISTFILESIZE=10000

# # for hh -> https://github.com/dvorka/hstr
# export HSTR_CONFIG=hicolor,rawhistory
# # history file sync ; careful with this option since history will be mixed between terminals
# # PROMPT_COMMAND="history -a; history -n"
# if hash /usr/bin/hh 2>/dev/null; then
# 	# if this is interactive shell, then bind hh to Ctrl-r (for Vi mode check doc)
# 	if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hh -- \C-m"'; fi
# 	# if this is interactive shell, then bind 'kill last command' to Ctrl-x k
# 	if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hh -k \C-m"'; fi
# fi

# ===============
#    PROMPT
# ==============

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
	if [ -f ~/.bash/prompts/prompt_7.sh ]; then
		source ~/.bash/prompts/prompt_7.sh
	fi
else
	PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Automatically trim long paths in the prompt (requires Bash 4.x)
# PROMPT_DIRTRIM=2

# ==============

# Source all .sh files inside ./bash (only files)
for file in ~/.bash/*.sh ; do
	[[ -f $file ]] && source $file
done
unset file

# enable programmable completion features
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		source /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		source /etc/bash_completion
	fi

	if [ -f /usr/share/bash-completion/completions/hub ]; then
		source /usr/share/bash-completion/completions/hub
		alias __git=hub
	fi
fi

# source keychain file if it exists
if [ -f ~/.keychain/$HOSTNAME-sh ]; then
	source ~/.keychain/$HOSTNAME-sh
fi

# Print logo when exiting
# print_on_exit () { printf "$(cat ~/.banner)"; sleep 0.3; }
# trap print_on_exit EXIT

# konsole background blur (not needed for latest console versions)
# if [[ $UID != 0 && -z $SSH_CLIENT ]]; then
# 	if hash qdbus 2>/dev/null && qdbus &>/dev/null; then
# 		konsolex=$(qdbus | grep konsole | cut -f 2 -d\ )
# 		if [ -n konsolex ]; then
# 			for konsole in $konsolex; do
# 				xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id \
# 					`qdbus $konsole /konsole/MainWindow_1 winId`;
# 			done
# 		fi
# 	fi
# fi

# ==============
#   VARIABLES
# ==============

#export LS_COLORS="$LS_COLORS:*.c=1;36:*.h=00;36"
export MYSQL_PS1="\u - \d > "
export EDITOR="vim"
# add customs scripts
export PATH=$HOME/.bash/scripts:$PATH

# ble.sh
((_ble_bash)) && ble-attach
