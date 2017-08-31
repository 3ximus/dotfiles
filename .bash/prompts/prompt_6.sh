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
	[[ -z $2 ]] && echo -en "\[\033[${1}m\]" || echo -en "\033[${1}m"
}

__rafg() {
# extract background and apply it to the foreground of powerline arrow
	# REGEX find 4 followed by a digit (negative lookback and lookahead of a digit character)
	fg=$(echo $1 | perl -ne '/(?<!\d)(4\d)(?!\d)/; $r = $1; $r =~ s/^4/3/; print $r;')
	[[ -z $2 ]] && echo -en "\[\033[${fg}m\]" || echo -en "\033[${fg}m"
}

__rabg() {
# extract background from given color and apply it to the powerline arrow
	bg=$(echo $1 | perl -ne '/(?<!\d)(4\d)(?!\d)/; print $1;')
	[[ -z $2 ]] && echo -en "\[\033[${bg}m\]" || echo -en "\033[${bg}m"
}

__segment() {
#XXX NOTE if a third argument is a given and is a non-empty string the usual escape sequences will not be printed
	echo -en "\e[1D$(__rabg $2 $3)$(__color $2 $3) $1 $(__color 0 $3)$(__rafg $2 $3)"
}

__virtual_env_segment () {
# this segment has to be handmade since it is evaluated every time the prompt is written, and prompt escape sequences are not handled dynamicly apparently
	if [ -z "$VIRTUAL_ENV_DISABLE_PROMPT" ] ; then
		if [ "$VIRTUAL_ENV" != "" ] ; then
			c1=$(echo $VenvColor | perl -ne '/(?<!\d)(4\d)(?!\d)/; print $1;')
			c2=$(echo $VenvColor | perl -ne '/(?<!\d)(4\d)(?!\d)/; $r = $1; $r =~ s/^4/3/; print $r;')
			echo -en "\e[1D\e[${c1}m\e[${VenvColor}m venv:`basename \"$VIRTUAL_ENV\"` \e[${c2}m"
		fi
	fi
}

# -----------------
# PROMPT DEFINITION
# -----------------

# count segment done manually
ALT_PS1="$(__color "$CountColor")#\#\[$(__rafg "$CountColor")\]\$([ \j -gt 0 ] && __segment \"bg:\j\" \"$JobColor\" \"-\")\$(__virtual_env_segment)$(__segment "\w" "$DirColor" )"

ALT_PS2="$(__segment "\u" "$MainColor")$(__color 0)\$([[ \$_COMMAND_FAILED_ == 1 ]] && echo -e \"$(__color "$ErrorColor")\") \\$ $(__color 0)"

# use prompt command to save last command exit status to a variable and generate the rest of the prompt
prompt_function() {
	[[ $? != 0 ]] && _COMMAND_FAILED_=1 || _COMMAND_FAILED_=0
	__git_ps1 "$ALT_PS1" "$ALT_PS2" "\b$(__color "$GitColor") ⎇%s  \[$(__rafg $GitColor)\]"
}

PROMPT_COMMAND='prompt_function'

