# vi: tabstop=4 filetype=bash

# ==================================
# ----------------------------------
# -------------WRAPPERS-------------
# ----------------------------------
# ==================================

# Color man pages
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;36m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;30m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;35m") \
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
	local REPLY
	find . -iname "*$1*"
	read -r -n 1 -p "Remove these files? [y/n]: " REPLY
	case "$REPLY" in
		[yY])		echo; find . -iname "*$1*" -exec rm -r "{}" \; ;;
		*)			echo -e "\nNothing deleted." ;;
	esac

}

delete_older_than_xdays() {
	if [ $# -eq 0 ] ; then
		echo 'delete_older_than_xdays N_DAYS [path]'
	else
		if [ $# -ne 1 ] ; then
			find . -mtime +$1 -delete
		else
			find "$2" -mtime +$1 -delete
		fi
	fi
}

# Simplify searching for keyword in current dir, and allow to pass more parameters to grep
grephere() {
	grep -e "$1" "${@:2}" -d recurse .
}

remove-special-chars-from-name() {
	local f
	if [[ -z $1 ]]; then
		echo "Give a file as argument"
		exit 1
	fi
	if [[ "$1" == "-r" ]]; then # all files inside a directory
		for f in ${2}/*\ *; do
			mv "$f" "${f//[\ \(\)\[\]]/_}";
		done
	else # single file
		mv "$1" "${1//[\ \(\)\[\]]/_}";
	fi
}

# preview markdown files as a man page
md() {
	pandoc -sf markdown -t man "$1" | man -l -
}


# Extract files
extract () {
	local f
	for f in "${@}" ; do
		echo extracting $f
		if [ -f "$f" ] ; then
			case "$f" in
				*.tar.bz2)	 echo "tar xjf $f"	&& tar xjf "$f"				;;
				*.tar.gz)	 echo "tar xzf $f"	&& tar xzf "$f"				;;
				*.tar.xz)	 echo "tar xJf $f"	&& gunzip "$f"				;;
				*.bz1)		 echo "bunzip2 $f"	&& bunzip2 "$f"				;;
				*.rar)		 echo "unrar e $f"	&& unrar x "$f"				;;
				*.gz)		 echo "gunzip $f"  && gunzip "$f"				;;
				*.tar)		 echo "tar xf $f"  && tar xf "$f"				;;
				*.tbz2)		 echo "tar xjf $f"	&& tar xjf "$f"				;;
				*.tgz)		 echo "tar xzf $f"	&& tar xzf "$f"				;;
				*.zip)		 echo "unzip $f"  && unzip "$f"					;;
				*.Z)		 echo "uncompress $f"  && uncompress "$f"		;;
				*.7z)		 echo "7z x $f"  && 7z x "$f"					;;
				*)			 echo "'$f' cannot be extracted via extract()"	;;
			esac
		else
			echo "'$f' is not a valid file"
		fi
	done
}

# i hate typing extract...
alias un=extract

# GIT

# delete files from cache
git-delete-cached() {
	git filter-branch --force --index-filter "git rm --cached --ignore-unmatch $@" --prune-empty --tag-name-filter cat -- --all
}

glfzf() {
	git rev-parse --is-inside-work-tree >/dev/null || return 1
	local cmd opts files
	files=$(sed -nE 's/.* -- (.*)/\1/p' <<< "$*") # extract files parameters for `git show` command
	cmd="echo {} |grep -Eo '[a-f0-9]+' |head -1 |xargs -I% git show --color=always % -- $files | delta"
	opts="
		--tiebreak=index
		--bind=\"enter:execute($cmd | LESS='-r' less)\"
		--bind=\"ctrl-y:execute-silent(echo {} |grep -Eo '[a-f0-9]+' | head -1 | tr -d '\n')\"
	"
	eval "git lol $* " | FZF_DEFAULT_OPTS="$opts" fzf --preview="$cmd" --ansi --no-sort --no-multi --reverse
}

# activate a virtual environment
activate() {
	local path=${1:-'.'}
	# local venvs=$(find . -regex .*activate$ | awk --field-separator=/ '{print $(NF-2)}')
	local venvs=$(find . -regex .*activate$)
	if [ $# -eq 0 ] ; then
		if [ $(find . -regex .*activate$ |wc -l) -gt 1 ] ; then
			echo "Found multiple Virtual Environments:"
			select vv in $venvs ; do
				acfile=$vv
				break
			done
		else
			acfile=$venvs
		fi
	else
		acfile=$(find $path -regex .*activate$)
	fi

	[[ -f $acfile ]] && {
		echo -e "Activating: \033[1;35m$acfile\033[m"
		source $acfile
	}

}

# find process by name
psgrep() {
	local list=$(ps -ef)
	echo -e "$list" | head -n1
	echo -e "$list" | grep -i $1 --color=always | grep -v grep
}

memhogs () {
	local TR=`free|grep Mem:|awk '{print $2}'`

	ps axo rss,comm,pid | awk -v tr=$TR '{proc_list[$2]+=$1;} END {for (proc in proc_list) {proc_pct=(proc_list[proc]/tr)*100; printf("%d\t%-16s\t%0.2f%%\n",proc_list[proc],proc,proc_pct);}}' | sort -rn | head -n 10
}

psmem () { # not working properly
	[[ $# -eq 0 ]] && { echo "Give some process names to search for" ; return 1; }

	local PROCNAME="$@";

	echo $PROCNAME IS USING \
	$(
		echo "scale=4; ($( ps axo rss,comm | grep $PROCNAME | awk '{ TOTAL += $1 } END { print TOTAL }' )/$( free | head -n 2 | tail -n 1 | awk '{ print $2 }' ))*100" | bc
	)% of system RAM;
}

download_m3u8_to_mp4() { # download m3u8 stream to an mp4 file
	ffmpeg -i "$1" -c copy -bsf:a aac_adtstoasc output.mp4
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


# ==================================
# ----------------------------------
# -------------OTHERS---------------
# ----------------------------------
# ==================================

# Use -p to make prompt changes permanent on .bashrc
prompt() {
	local bashrc=$([[ -L "$HOME/.bashrc" ]] && echo `file "$HOME/.bashrc" | cut -d' ' -f5` || echo "$HOME/.bashrc")
	if [ -f ~/.bash/prompts/prompt_${1}.sh ]; then
		[[ ! -z $2 ]] && [[ $2 == "-p" ]] && sed -i "s/prompt_[0-9]\.sh[^\ \n]*/prompt_${1}\.sh/" $bashrc || echo "Use -p to make changes permanent on .bashrc";
		echo "Sourcing ~/.bash/prompts/prompt_${1}.sh"
		source ~/.bash/prompts/prompt_${1}.sh
	fi
}

# Display unicode chars
unicode() {
	local a b c
	for a in {0..9} {a..f}; do
		for b in {0..9} {a..f}; do
			printf "${a}${b}00	"
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
	local i FGs FG column
	if [[ -z $1 || $1 == 1 ]]; then
		echo -en '\n	 '
		for i in {0..7} ; do printf "\e[48;5;${i}m	   "; done
		echo -en '\e[0m\n	  '
		for i in {0..7} ; do printf "\e[48;5;${i}m	   "; done
		echo -en '\e[0m\n	  '
		for i in {8..15} ; do printf "\e[48;5;${i}m		"; done
		echo -en '\e[0m\n	  '
		for i in {8..15} ; do printf "\e[48;5;${i}m		"; done
		printf "\e[0m\n\n"
	elif [[ $1 == 2 ]]; then
		echo -e "\n					40m		41m		42m		43m		44m		45m		46m		47m";
		for FGs in '	m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
			'1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
				'  36m' '1;36m' '  37m' '1;37m';
			do FG=${FGs// /}
			echo -en " $FGs \033[$FG  eXz  "
				for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
			do echo -en " \033[$FG\033[$BG	eXz  \033[0m";
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
		local base=( 16 52 88 124 160 196 232 34 70 106 142 178 214 250)
		for i in {0..17}; do
			for column in $(seq 0 $((${#base[@]} - 1))) ; do
				if [[ ${column} -ge 6 ]] ; then
					fg='38;5;232';
				else
					fg=''
				fi
				[[ $column == 7 ]] && echo -en '\e[0m  '
				printf "\e[${fg};48;5;%dm% 4d" ${base[$column]} ${base[$column]}
				base[$column]=$((${base[$column]} + 1))
			done
			echo -ne '\e[0m\n  '
		done
		echo
	fi
}
