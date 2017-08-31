#! /bin/sh
# BACKGROUND COLORED DUAL SIDES BASH PROMPT
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
    bgcolor=";41"; # red
    fgcolor="";
    sfgcolor=";31";
else
    bgcolor=";42"; # green
    fgcolor=";30";
    sfgcolor=";32";
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
            echo -e "\b\033[$sfgcolor;40m\033[34;40m venv:`basename \"$VIRTUAL_ENV\"` \033[30;44m"
        fi
    fi
}

ALT_PS1="\[\033["$fgcolor$bgcolor"m\] \u@\h \[\033["$sfgcolor";44m\]\$(_add_venv_info)\[\033[30;44m\] \$(_path) \[\033[0m\]\[\033[34m\] \[\033[0m\]\e[?7l$DASHES\e[?7h\e[\$(echo -e \$(__git_ps1 '\ \(%s)')\ \d\ \ \ \ \$(tty | sed 's/\/dev\///') | wc -c)D"
ALT_PS2="\[\033[32m\]\[\033[30;42m\] \$(tty | sed 's/\/dev\///')  \d \[\033[0m\]\n\$([ \j -gt 0 ] && echo -e \"\[\033[33;40m\] \j \[\033[30"$bgcolor"m\]\")\[\033["$fgcolor$bgcolor"m\] \\$ \$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \"\[\033["$sfgcolor";41m\]\[\033[0;41m\] \342\234\226 \[\033[0m\]\[\033[31m\]\" || echo -e \"\[\033[0m\]\[\033["$sfgcolor"m\]\" )\[\033[0m\] "
# use prompt command to save last command exit status to a variable and generate the rest of the prompt
PROMPT_COMMAND='[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0; __git_ps1 "$ALT_PS1" "$ALT_PS2" "\[\033[33m\]\[\033[30;43m\]  %s "'

