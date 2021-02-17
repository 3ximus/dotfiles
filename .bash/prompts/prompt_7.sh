#! /bin/bash
# ONE LINE CLEAN AND SIMPLE PROMPT
# by eximus

# -----------------
# GIT VARIABLES
# -----------------
GIT_PS1_SHOWDIRTYSTATE='nonempty' # show + for staged and * for unstaged
GIT_PS1_SHOWSTASHSTATE='nonempty' # show $ for stash
GIT_PS1_SHOWUNTRACKEDFILES='nonempty' # show % if untracked files exist
GIT_PS1_SHOWCOLORHINTS='' # hide status colors
GIT_PS1_SHOWUPSTREAM='auto' # see diference from upstream: > ahead, < behind, <> diverging = equal (use verbose to see number of commits ahed or behind)
GIT_PS1_DESCRIBE_STYLE='branch'

# -----------------
# COLORS
# -----------------
__UserColor="1;30"
__RootColor="1;31"
__SSHColor="1;37"

__DirColor="1;34"
__CountColor="37"
__GitColor="1;33"
__JobColor="1;35"
__VenvColor="1;30"
__VirtColor="1;36"

__ErrorColor="1;31"

# setup color for diferent users
if [[ ${EUID} == 0 ]]; then
	__MainColor=$__RootColor
elif [[ -n $SSH_CLIENT ]]; then
	__MainColor=$__SSHColor
else
	__MainColor=$__UserColor
fi

# -----------------
# FUNCTIONS
# -----------------

__color() {
	echo -en "\001\033[${1}m\002"
}

__virtual_env () {
	if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
		if [ ! -z "$VIRTUAL_ENV" ] ; then
			echo -en " \001\e[${__VenvColor}m\002[`basename \"$VIRTUAL_ENV\"`]"
		elif [ ! -z "$CONDA_PROMPT_MODIFIER" ] ; then
			echo -en " \001\e[${__VenvColor}m\002[$CONDA_PROMPT_MODIFIER]"
		fi
	fi
}

__nested_level () {
	if [ "$SHLVL" -gt 1 ]; then
		echo -en "^"
	fi
}

__virtualization () {
	if hash systemd-detect-virt 2>/dev/null ; then
		[ `systemd-detect-virt` != "none" ]
		out=$?
	elif hash hostnamectl 2>/dev/null ; then
		hostnamectl status | grep 'Virt' &>/dev/null
		out=$?
	fi
	[[ $out = 0 ]] && echo -en " \001\e[${__VirtColor}m\002(vm)"
}


__job_count() {
	local stopped=$(jobs -sp |wc -l)
	local running=$(jobs -rp |wc -l)
	((running+stopped)) && echo -n " {"
	[[ $stopped -ne 0 ]] && echo -n "${stopped}"
	[[ $running -ne 0 ]] && echo -n "+${running}"
	((running+stopped)) && echo -n "}"
}

# -----------------
# PROMPT DEFINITION
# -----------------

ALT_PS1="$(__color "$__CountColor")#\#\$(__virtualization)$(__color "$__JobColor")\$(__job_count)\$([[ \$__MainColor != \$__UserColor ]] && echo \"$(__color "$__MainColor") \u@\h\") $(__color "$__DirColor")\w\$(__virtual_env)"

ALT_PS2="$(__color 0) \$(__nested_level)\$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \"$(__color "$__ErrorColor")\")\\$ $(__color 0)"

# use prompt command to save last command exit status to a variable and generate the rest of the prompt
__prompt_function() {
	[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0
	__git_ps1 "$ALT_PS1" "$ALT_PS2" "$(__color "$__GitColor") %s"
}

PROMPT_COMMAND='__prompt_function'

