__print_colored_content() {
	[ "${2:0:1}" = "#" ] && BGCOLOR="$2" || BGCOLOR="colour$2"
	[ "${3:0:1}" = "#" ] && FGCOLOR="$3" || FGCOLOR="colour$3"
	if [[ "$2" = "default" || -z "$2" ]]; then
		echo -n "#[fg=${FGCOLOR}]"
	elif [[ "$3" = "default" || -z "$3" ]]; then
		echo -n "#[bg=${BGCOLOR}]"
	else
		echo -n "#[fg=${FGCOLOR},bg=${BGCOLOR}]"
	fi
	echo -n "$1"
	echo -n "#[default]"
}
