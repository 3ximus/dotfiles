#! /bin/sh
# ONE LINE CLEAN AND SIMPLE PROMPT
# by eximus

# -----------------
# GIT VARIABLES
# -----------------
GIT_PS1_SHOWDIRTYSTATE='nonempty' # show + for staged and * for unstaged
GIT_PS1_SHOWSTASHSTATE='nonempty' # show $ for stash
GIT_PS1_SHOWUNTRACKEDFILES='nonempty' # show % if untracked files exist
GIT_PS1_SHOWCOLORHINTS='' # hide status colors
GIT_PS1_SHOWUPSTREAM='verbose' # see diference from upstream: > ahead, < behind, <> diverging = equal (use verbose to see number of commits ahed or behind)
GIT_PS1_DESCRIBE_STYLE='branch'

# -----------------
# COLORS
# -----------------
UserColor="1;30"
RootColor="1;31"
SSHColor="1;36"

DirColor="1;34"
CountColor="37"
GitColor="1;33"
JobColor="1;36"
VenvColor="1;30"

ErrorColor="1;31"

# setup color for diferent users
if [[ ${EUID} == 0 ]]; then
	MainColor=$RootColor
elif [[ -n $SSH_CLIENT ]]; then
	MainColor=$SSHColor
else
	MainColor=$UserColor
fi

# -----------------
# FUNCTIONS
# -----------------

__color() {
	echo -en "\[\033[${1}m\]"
}

__virtual_env_segment () {
	if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
		if [ "$VIRTUAL_ENV" != "" ] ; then
			echo -en " [\001\e[${VenvColor}m\002`basename \"$VIRTUAL_ENV\"`]"
		fi
	fi
}

# -----------------
# PROMPT DEFINITION
# -----------------

ALT_PS1="$(__color "$CountColor")#\#\$([ \j -gt 0 ] && echo \"$(__color $JobColor) bg:\j\")\$(__virtual_env_segment)\$([[ \$MainColor != \$UserColor ]] && echo \"$(__color "$MainColor") \u@\h\") $(__color "$DirColor")\w"

ALT_PS2="$(__color 0) \$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \"$(__color "$ErrorColor")\")\\$ $(__color 0)"

# use prompt command to save last command exit status to a variable and generate the rest of the prompt
__prompt_function() {
	[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0
	__git_ps1 "$ALT_PS1" "$ALT_PS2" "$(__color "$GitColor") %s"
}

PROMPT_COMMAND='__prompt_function'

