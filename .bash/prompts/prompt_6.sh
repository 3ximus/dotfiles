#! /bin/sh
# ONE LINE SORT OF POWERLINE
# NOTE: this prompt doesnt work for 256 colors in the text background (doesnt apply them to the powerline arrows correctly)
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
UserColor="36;40"
RootColor="37;41"
SSHColor="30;46"

DirColor="30;44"
CountColor="30;47"
GitColor="30;43"
JobColor="30;46"
VenvColor="35;40"

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
	echo -en "\001\033[${1}m\002"
}

__rafg() {
# extract background and apply it to the foreground of powerline arrow
	# REGEX find 4 followed by a digit (negative lookback and lookahead of a digit character)
	fg=$(echo $1 | perl -ne '/(?<!\d)(4\d)(?!\d)/; $r = $1; $r =~ s/^4/3/; print $r;')
	echo -en "\001\033[${fg}m\002"
}

__rabg() {
# extract background from given color and apply it to the powerline arrow
	bg=$(echo $1 | perl -ne '/(?<!\d)(4\d)(?!\d)/; print $1;')
	echo -en "\001\033[${bg}m\002"
}

__segment() {
	echo -en "\001\b\002$(__rabg $2)$(__color $2) $1 $(__color 0)$(__rafg $2)"
}

__virtual_env_segment () {
# this segment has to be handmade since it is evaluated every time the prompt is written, and prompt escape sequences are not handled dynamicly apparently
	if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
		if [ "$VIRTUAL_ENV" != "" ] ; then
			c1=$(echo $VenvColor | perl -ne '/(?<!\d)(4\d)(?!\d)/; print $1;')
			c2=$(echo $VenvColor | perl -ne '/(?<!\d)(4\d)(?!\d)/; $r = $1; $r =~ s/^4/3/; print $r;')
			echo -en "\001\b\002\001\e[${c1}m\e[${VenvColor}m\002 venv:`basename \"$VIRTUAL_ENV\"` \001\e[${c2}m\002"
		fi
	fi
}

# -----------------
# PROMPT DEFINITION
# -----------------

# count segment done manually
ALT_PS1="\[$(__color "$CountColor")\]#\#\[$(__rafg "$CountColor")\]\[\$([ \j -gt 0 ] && __segment \"bg:\j\" \"$JobColor\")\]\$(__virtual_env_segment)$(__segment "\w" "$DirColor" )"

ALT_PS2="$(__color 0) \$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \"$(__color "$ErrorColor")\")\\$ $(__color 0)"

# use prompt command to save last command exit status to a variable and generate the rest of the prompt
__prompt_function() {
	[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0
	[[ "$MainColor" != "$UserColor" ]] && _USER_=$(__segment "\u@\h" "$MainColor") || _USER_=""
	__git_ps1 "$ALT_PS1" "$_USER_$ALT_PS2" "\[\b\]$(__color "$GitColor") %s $(__color 0)$(__rafg $GitColor)"
}

PROMPT_COMMAND='__prompt_function'

