#! /bin/sh
# BACKGROUND COLORED DUAL SIDES BASH PROMPT
# Less colored variation of prompt 2 to be more adaptable with some themes
# Currently set to fit Arc Theme
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
	MainColor="1" # red
	BGMainColor="4$MainColor"
	FGMainColor="0"
	sFGMainColor="3$MainColor" # background as foreground
else
	MainColor="0" # black
	BGMainColor="4$MainColor"
	FGMainColor="0" # white
	sFGMainColor="3$MainColor" # background as foreground
fi

# Alternative theme color
AltColor="4" # blue
BGAltColor="4$AltColor"
FGAltColor="30"
sFGAltColor="3$AltColor" # background as foreground

GitColor="3"
JobColor="6"
VenvColor="5" # virtual environment color

__colorize() {
	echo -en "\[\033[${1}m\]"
}

__path() { # normal path can be printed on the prompt with \w
	#path calc
	local repo
	local repo_sub
	local code
	local code_sub
	repo="~/Documents/rep/"
	repo_sub="R:"
	code="~/Documents/code/"
	code_sub="C:"
	echo $PWD | sed "s@$HOME@\~@" | sed "s@$repo@$repo_sub@" | sed "s@$code@$code_sub@"
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
			echo -e "\b\033[$sFGMainColor;4${VenvColor}m\033[1;30;4${VenvColor}m${VIRT_ENV_TXT}\033[0;3${VenvColor};${BGAltColor}m"
		fi
    fi
}

ALT_PS1="$(__colorize "$FGMainColor;1;$BGMainColor") \u@\h $(__colorize "0;$sFGMainColor;$BGAltColor")\$(__add_venv_info)$(__colorize "$FGAltColor;1;$BGAltColor") \$(__path) $(__colorize "0;$sFGAltColor") \[\033[0m\]\e[?7l$DASHES\e[?7h\e[\$(echo -e \$(__git_ps1 '\ \(%s)')\ \d\ \ \ \ \$(tty | sed 's/\/dev\///') | wc -c)D"

ALT_PS2="\[\033[${sFGAltColor}m\]$(__colorize "1;$FGAltColor;$BGAltColor") \$(tty | sed 's/\/dev\///') $(__colorize "0;$sFGMainColor;$BGAltColor")$(__colorize "$FGMainColor;1;$BGMainColor") \d \[\033[0m\]\n\$([ \j -gt 0 ] && echo -e \"$(__colorize "$FGAltColor;4$JobColor") \j $(__colorize "$BGMainColor;3$JobColor")\")$(__colorize "0;$FGMainColor;1;$BGMainColor") \\$ \$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \"$(__colorize "0;$sFGMainColor;41")\[\033[0;41m\] \342\234\226 \[\033[0;31m\]\" || echo -e \"\[\033[0;${sFGMainColor}m\]\" )\[\033[0m\] "

# use prompt command to save last command exit status to a variable and generate the rest of the prompt
PROMPT_COMMAND='[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0; __git_ps1 "$ALT_PS1" "$ALT_PS2" "$(__colorize "3$GitColor")$(__colorize "$FGAltColor;1;43")  %s $(__colorize "0;43")"'

