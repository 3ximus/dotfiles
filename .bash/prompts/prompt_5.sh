#! /bin/sh
# SIMPLE COLORED DUAL SIDES BASH PROMPT
# by eximus

DASHES="$(printf ' %0.s' {1..400})" # used to fill the screen together with escape sequences

# git variables for prompt
GIT_PS1_SHOWDIRTYSTATE='nonempty' # show + for staged and * for unstaged
GIT_PS1_SHOWSTASHSTATE='nonempty' # show $ for stash
GIT_PS1_SHOWUNTRACKEDFILES='nonempty' # show % if untracked files exist
GIT_PS1_SHOWCOLORHINTS='' # hide status colors
GIT_PS1_SHOWUPSTREAM='git' # see diference from upstream: > ahead, < behind, <> diverging = equal (use verbose to see number of commits ahed or behind)

# setup color for diferent users
if [[ ${EUID} == 0 ]]; then
	MainColor="31" # red
elif [[ -n $SSH_CLIENT ]]; then
	MainColor="33" # yellow
else
	MainColor="32" # green
fi

AltColor="34" # blue
GitColor="33"
JobColor="36"
VenvColor="35" # virtual environment color

__colorize() {
	echo -en "\[\033[${1}m\]"
}

__add_venv_info () {
    if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
        VIRT_ENV_TXT=""
        if [ "x" != x ] ; then
            VIRT_ENV_TXT=""
        else
             [ "$VIRTUAL_ENV" != "" ] && VIRT_ENV_TXT=" venv:`basename \"$VIRTUAL_ENV\"` "
        fi
        if [ "${VIRT_ENV_TXT}" != "" ];then
			echo -e "${VIRT_ENV_TXT}"
		fi
    fi
}

ALT_PS1="┌ $(__colorize "1;$AltColor")\w $(__colorize "1;$VenvColor")\$(__add_venv_info)$(__colorize 0)\e[?7l$DASHES\e[?7h\e[\$(echo -en \$(__git_ps1 'xx%s')\$([ \j -gt 0 ] && echo -en \"bg: \j\" )\$(tty | tr --delete '\n' | sed 's/\/dev\///') | wc -c)D"

ALT_PS2="\$([ \j -gt 0 ] && echo -en \"$(__colorize "1;$JobColor") bg:\j\")$(__colorize "0;1") \$(tty | tr --delete '\n' | sed 's/\/dev\///')\n$(__colorize 0)└ $(__colorize "1;$MainColor")\u@\h$(__colorize 0) \$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \" $(__colorize 31)✖ $(__colorize 0)\") \\$ "

# use prompt command to save last command exit status to a variable and generate the rest of the prompt
PROMPT_COMMAND='[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0; __git_ps1 "$ALT_PS1" "$ALT_PS2" "$(__colorize "1;$GitColor") %s"'

