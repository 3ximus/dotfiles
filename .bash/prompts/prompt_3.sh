#! /bin/sh
# SIMPLER DUAL SIDES BASH PROMPT
# by eximus

DASHES="$(printf ' %0.s' {1..400})" # used to fill the screen together with escape sequences

# git variables for prompt
GIT_PS1_SHOWSTASHSTATE='nonempty' # show $ for stash
GIT_PS1_SHOWDIRTYSTATE='nonempty' # show + for staged and * for unstaged
GIT_PS1_SHOWUNTRACKEDFILES='nonempty' # show % if untracked files exist
GIT_PS1_SHOWCOLORHINTS='' # hide status colors
GIT_PS1_SHOWUPSTREAM='git' # see diference from upstream: > ahead, < behind, <> diverging = equal (use verbose to see number of commits ahed or behind)

rd="\[\033[0;31m\]"
gr="\[\033[0;32m\]"
yl="\[\033[0;33m\]"
bl="\[\033[0;34m\]"
pn="\[\033[0;35m\]"
pu="\[\033[1;36m\]"
bb="\[\033[0m\]"

# setup color for diferent users
if [[ ${EUID} == 0 ]];then
    u=$rd
    uc=$rd
    ub="\[\033[1;31m\]"
else
    u=$gr
    uc="\[\033[29m\]"
    ub="\[\033[1;32m\]"
fi

#path calc
repo="~/Documents/rep/"
repo_sub="R:"
code="~/Documents/code/"
code_sub="C:"

_path() { # normal path can be printed on the prompt with \w
    echo $PWD | sed "s@$HOME@\~@" | sed "s@$repo@$repo_sub@" | sed "s@$code@$code_sub@"
}

_add_venv_info () {
    if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
        if [ "$VIRTUAL_ENV" != "" ];then
            echo -e "\033[35m venv:`basename \"$VIRTUAL_ENV\"` "
        fi
    fi
}

ALT_PS1="$u\u$bb ❯ $gr\h$bb ❯\$(_add_venv_info) $bl\$(_path)$bb\e[?7l$DASHES\e[?7h\e[\$(echo -e \$(__git_ps1 '\ \(%s)')\ \$(tty | sed 's/\/dev\///')\$([ \j -gt 0 ] && echo -e 0000) | wc -c)D"
ALT_PS2="\$([ \j -gt 0 ] && echo -e \"$pn\j$bb ❮ \")$pu\$(tty | sed 's/\/dev\///')$bb\n\$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \" $rd\342\234\226$bb \")\[\033[1;30m\]❯$ub❯$u❯$bb "
# use prompt command to save last command exit status to a variable and generate the rest of the prompt
PROMPT_COMMAND='[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0; __git_ps1 "$ALT_PS1" " $ALT_PS2" "$yl \\342\\216\\207  %s $bb❮"'

