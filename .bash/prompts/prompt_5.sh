#! /bin/sh
# SIMPLE COLORED DUAL SIDES BASH PROMPT
# by eximus

DASHES="$(printf ' %0.s' {1..400})" # used to fill the screen together with escape sequences

# git variables for prompt
GIT_PS1_SHOWDIRTYSTATE='nonempty' # show + for staged and * for unstaged
GIT_PS1_SHOWSTASHSTATE='nonempty' # show $ for stash
GIT_PS1_SHOWUNTRACKEDFILES='nonempty' # show % if untracked files exist
GIT_PS1_SHOWCOLORHINTS='' # hide status colors
GIT_PS1_SHOWUPSTREAM='verbose' # see diference from upstream: > ahead, < behind, <> diverging = equal (use verbose to see number of commits ahed or behind)
GIT_PS1_DESCRIBE_STYLE='branch'

UserColor="38;5;2" # green
RootColor="31" # red
SSHColor="33" # yellow

DirColor="38;5;4" # blue
CountColor="38;5;243" # dark grey
GitColor="38;5;3" # yellow
JobColor="36"
VenvColor="35"

# setup color for diferent users
if [[ ${EUID} == 0 ]]; then
    MainColor=$RootColor
elif [[ -n $SSH_CLIENT ]]; then
    MainColor=$SSHColor
else
    MainColor=$UserColor
fi

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

ALT_PS1="┌ $(__colorize "$DirColor")\w $(__colorize "1;$VenvColor")\$(__add_venv_info)$(__colorize 0)\e[?7l$DASHES\e[?7h\e[\$(echo -en \$(__git_ps1 'xx%s')\#xx\$([ \j -gt 0 ] && echo -en \"bg: \j\" )\$(tty | tr --delete '\n' | sed 's/\/dev\///') | wc -c)D"

ALT_PS2="\$([ \j -gt 0 ] && echo -en \"$(__colorize "$JobColor") bg:\j\")$(__colorize "0") $(__colorize "$CountColor")#\#$(__colorize "0") \$(tty | tr --delete '\n' | sed 's/\/dev\///')\n$(__colorize 0)└ $(__colorize "$MainColor")\u@\h$(__colorize 0) \$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \" $(__colorize 31)✖ $(__colorize 0)\") \\$ "

# use prompt command to save last command exit status to a variable and generate the rest of the prompt
PROMPT_COMMAND='[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0; __git_ps1 "$ALT_PS1" "$ALT_PS2" "$(__colorize "$GitColor")⎇ %s"'

