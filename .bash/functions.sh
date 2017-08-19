#! /bin/sh

# ==================================
# ----------------------------------
# -------------WRAPPERS-------------
# ----------------------------------
# ==================================

# Color man pages
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;30m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
			man "$@"
}

# execute a function as sudo
sudofunction() {
	local tmpfile="/dev/shm/$RANDOM"
	declare -f "$1" | head -n -1 | tail -n +3 > "$tmpfile"
	sudo bash "$tmpfile" "${@:2}"
	rm "$tmpfile"
}

# Simplify searching for keyword in current dir
findhere() {
	find . -iname "*$1*" "${@:2}"
}

# Delete files with patern in current dir
findremove() {
	files=$(find . -iname "*$1*" -print | tee /dev/tty)
	read -r -n 1 -p "Remove these files? [y/n]: " REPLY
	case "$REPLY" in
		[yY])		echo; rm -r $files ;;
		*) 			echo -e "\nNothing deleted." ;;
	esac

}

# Simplify searching for keyword in current dir, and allow to pass more parameters to grep
grephere() {
	grep -e "$1" "${@:2}" -d recurse .
}

remove_space_from_name() {
	for f in ${1}/*\ *; do
		mv "$f" "${f// /_}";
	done
}

# Extract files
extract () {
	for f in "${@}" ; do
		echo extracting $f
		if [ -f "$f" ] ; then
			case "$f" in
				*.tar.bz2)	 echo "tar xjf $f"	&& tar xjf "$f"		 ;;
				*.tar.gz)	 echo "tar xzf $f"	&& tar xzf "$f"		 ;;
				*.bz1)		 echo "bunzip2 $f"	&& bunzip2 "$f"		 ;;
				*.rar)		 echo "unrar e $f"	&& unrar e "$f"		 ;;
				*.gz)		 echo "gunzip $f"  && gunzip "$f"			 ;;
				*.tar)		 echo "tar xf $f"  && tar xf "$f"			 ;;
				*.tbz2)		 echo "tar xjf $f"	&& tar xjf "$f"		 ;;
				*.tgz)		 echo "tar xzf $f"	&& tar xzf "$f"		 ;;
				*.zip)		 echo "unzip $f"  && unzip "$f"			 ;;
				*.Z)		 echo "uncompress $f"  && uncompress "$f"  ;;
				*.7z)		 echo "7z x $f"  && 7z x "$f"				 ;;
				*)			 echo "'$f' cannot be extracted via extract()" ;;
			esac
		else
			echo "'$f' is not a valid file"
		fi
	done
}

# i hate typing extract...
alias unpack=extract

# find process by name
psgrep() {
	list=$(ps aux)
	echo -e "$list" | head -n1
	echo -e "$list" | grep $1 --color=always | grep -v grep
}

vboxsave() {
	vboxmanage controlvm $1 savestate
}

# fork to the background silently and send its output to the /dev/null
# NOTES: generic form #>/dev/null (# is 1 by default)
#		2>&-			---->		#>&-   (close fd)
#		|&				---->		2>&1
#		&>/dev/null		---->		1>/dev/null 2>&1
ds() {
	echo "$@ |& > /dev/null &"
	"$@" |& > /dev/null &
}

# fork and dissown command
dss() {
	$@ |& > /dev/null &
	disown %-
}


# ==================================
# ----------------------------------
# -------------OTHERS---------------
# ----------------------------------
# ==================================


# change input mode to emacs or vim
chinput() {
	local bashrc
	local inputrc
	bashrc=$([[ -L "$HOME/.bashrc" ]] && echo `file "$HOME/.bashrc" | cut -d' ' -f5` || echo "$HOME/.bashrc")
	inputrc=$([[ -L "$HOME/.inputrc" ]] && echo `file "$HOME/.inputrc" | cut -d' ' -f5` || echo "$HOME/.inputrc")
	if [ "$1" != "vi" ]; then
		sed -i '/.*\ vi$/s/vi/emacs/' $inputrc $bashrc;
		sed -i '/set\ show\-mode\-in\-prompt\ on/s/on$/off/' $inputrc;
	else
		sed -i '/.*\ emacs$/s/emacs/vi/' $inputrc $bashrc;
		sed -i '/set\ show\-mode\-in\-prompt\ off/s/off$/on/' $inputrc;
	fi
	bind -f $inputrc
}

# Use -p to make prompt changes permanent on .bashrc
prompt() {
	local bashrc
	bashrc=$([[ -L "$HOME/.bashrc" ]] && echo `file "$HOME/.bashrc" | cut -d' ' -f5` || echo "$HOME/.bashrc")
	if [ -f ~/.bash/prompts/prompt_${1}.sh ]; then
		[[ ! -z $2 ]] && [[ $2 == "-p" ]] && sed -i "s/prompt_[0-9]\.sh[^\ \n]*/prompt_${1}\.sh/" $bashrc || echo "Use -p to make changes permanent on .bashrc";
		echo "Sourcing ~/.bash/prompts/prompt_${1}.sh"
		source ~/.bash/prompts/prompt_${1}.sh
	fi
}

# Display unicode chars
unicode() {
	for a in {0..9} {a..f}; do
		for b in {0..9} {a..f}; do
			printf "${a}${b}00  "
			for c in {0..3}{{0..9},{a..f}} ; do printf "\u$a$b$c "; done
			printf "\n${a}${b}40  "
			for c in {4..7}{{0..9},{a..f}}; do printf "\u$a$b$c "; done
			printf "\n${a}${b}80  "
			for c in {{8..9},{a..b}}{{0..9},{a..f}}; do printf "\u$a$b$c "; done
			printf "\n${a}${b}c0  "
			for c in {c..f}{{0..9},{a..f}}; do printf "\u$a$b$c "; done
			echo
		done
	done | LESSUTFBINFMT='?' less
}

# Function to display terminal colors. $1 -> (1 - simple, 2 - with numbers, 3 - 256 colors)
colors() {
	if [[ -z $1 || $1 == 1 ]]; then
		echo -en '\n     '
		for i in {0..7} ; do printf "\e[48;5;${i}m     "; done
		echo -en '\e[0m\n     '
		for i in {0..7} ; do printf "\e[48;5;${i}m     "; done
		echo -en '\e[0m\n     '
		for i in {8..15} ; do printf "\e[48;5;${i}m     "; done
		echo -en '\e[0m\n     '
		for i in {8..15} ; do printf "\e[48;5;${i}m     "; done
		printf "\e[0m\n\n"
	elif [[ $1 == 2 ]]; then
		echo -e "\n                 40m     41m     42m     43m     44m     45m     46m     47m";
		for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
			'1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
				'  36m' '1;36m' '  37m' '1;37m';
			do FG=${FGs// /}
			echo -en " $FGs \033[$FG  eXz  "
				for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
			do echo -en " \033[$FG\033[$BG  eXz  \033[0m";
			done
			echo;
		done
		echo
	elif [[ $1 == 3 ]]; then
		echo -en '\n  '
		for i in {0..15} ; do
			[[ $i == 8 ]] && echo -en '\e[0m  '
			printf "\e[48;5;%dm%3d" $i $i
		done
		echo -ne '\e[0m\n\n  '
		base=( 16 52 88 124 196 232 34 70 106 142 214 250)
		for i in {0..17}; do
			for column in $(seq 0 $((${#base[@]} - 1))) ; do
				if [[ ${column} -ge 6 ]] ; then
					fg='38;5;232';
				else
					fg=''
				fi
				[[ $column == 6 ]] && echo -en '\e[0m  '
				printf "\e[${fg};48;5;%dm% 4d" ${base[$column]} ${base[$column]}
				base[$column]=$((${base[$column]} + 1))
			done
			echo -ne '\e[0m\n  '
		done
		echo
	fi
}
