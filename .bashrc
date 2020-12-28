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
bind Space:magic-space

# disable Ctrl-S ( flow control )
stty -ixon

# turn off feature to send focus gain or focus lost commands ^[[O ^[[I
printf "\e[?1004l" # doesn't look like it works

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

# ==================
#    TTY SPECIFIC
# ==================

# set tty colors to gruvbox :)
# NOTE: To use bold font use `sudo dpkg-reconfigure console-setup` and choose TerminusBold font
# or place this in /etc/default/console-setup
#    FONTFACE="TerminusBold"
if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0282828" #black
    echo -en "\e]P8928374" #darkgrey
    echo -en "\e]P1CC241D" #darkred
    echo -en "\e]P9FB4934" #red
    echo -en "\e]P298971A" #darkgreen
    echo -en "\e]PAB8BB26" #green
    echo -en "\e]P3D79921" #brown
    echo -en "\e]PBFaBD2F" #yellow
    echo -en "\e]P4458588" #darkblue
    echo -en "\e]PC83A598" #blue
    echo -en "\e]P5B16286" #darkmagenta
    echo -en "\e]PDD3869B" #magenta
    echo -en "\e]P6689D6A" #darkcyan
    echo -en "\e]PE8EC07C" #cyan
    echo -en "\e]P7A89984" #lightgrey
    echo -en "\e]PFEBDBB2" #white
    clear #for background artifacting
fi

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

# Source all .sh and .bash files inside ./bash (only files)
for file in ~/.bash/*.sh ~/.bash/*.bash ; do
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
    fi
fi

# source keychain file if it exists
if [ -f ~/.keychain/$HOSTNAME-sh ]; then
    source ~/.keychain/$HOSTNAME-sh
fi

# ==============
#   VARIABLES
# ==============
# This are basic variables, extra ones should be defined in variables.sh inside .bash

export EDITOR="vim"
# add customs scripts
export PATH=$HOME/.bash/scripts:$PATH

# ============================
# ble.sh
((_ble_bash)) && ble-attach
