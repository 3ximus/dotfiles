#! /bin/sh
# UNICODE LARGE BASH PROMPT
# by eximus

# customize prompt (\j for jobs \# number of executed commands \l for pts id \\$ for prompt)
DASHES="$(printf '\u2500%0.s' {1..400})" # used to fill the screen together with escape sequences
# to disable wrapping use: \e[?7l$DASHES\e[?7h  and the DASHES will be cut when end is reached
# use\e[15D to move cursor backwards 15 chars for example

# symbols
bar="\342\224\200"
dot_r="\342\225\272"
dot_l="\342\225\270"

#path calc
repo="~/Documents/rep/"
repo_sub="R:"
code="~/Documents/code/"
code_sub="C:"

_path() { # normal path can be printed on the prompt with \w
	echo $PWD | sed "s@$HOME@\~@" | sed "s@$repo@$repo_sub@" | sed "s@$code@$code_sub@"
}

# git variables for prompt
GIT_PS1_SHOWDIRTYSTATE='nonempty' # show + for staged and * for unstaged
GIT_PS1_SHOWSTASHSTATE='nonempty' # show $ for stash
GIT_PS1_SHOWUNTRACKEDFILES='nonempty' # show % if untracked files exist
GIT_PS1_SHOWCOLORHINTS='nonempty' # show status colors
GIT_PS1_SHOWUPSTREAM='git' # see diference from upstream: > ahead, < behind, <> diverging = equal (use verbose to see number of commits ahed or behind)

#TODO $? not showing because path is calculated before; XXX see prompt 2 for fix

ALT_PS1="\342\224\214$dot_l$(if [[ ${EUID} == 0 ]]; then echo '\[\033[1;31m\]\u\[\033[0m\]'; else echo '\u\[\033[0m\]'; fi)@\[\033[1;32m\]\h\[\033[0m\] $dot_l \[\033[1;34m\]\$(_path)\[\033[0m\] "
ALT_PS2="\$([[ \$_COMMAND_FAILED_ == 1 ]] && echo \"$dot_l \[\033[0;31m\]\342\234\226\[\033[0m\] \")\$([ \j -gt 0 ] && echo \"$dot_l \[\033[1;33m\]\j\[\033[0m\] \")$dot_r\e[?7l$DASHES\e[?7h\e[5D$dot_l\$(tty | sed 's/\/dev\///')\n\342\224\224$bar \342\235\257 "
PROMPT_COMMAND='[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0;__git_ps1 "$ALT_PS1" "$ALT_PS2" "\\342\\216\\207 %s "'

