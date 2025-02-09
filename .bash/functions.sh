# vi: tabstop=4 foldmethod=marker

# WRAPPERS
# ===================

# Color man pages
man() { # {{{
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;36m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;35m") \
			man "$@"
} # }}}

# execute a function as sudo
sudofunction() { # {{{
	# From : https://stackoverflow.com/a/12230307/4719158
	# I use underscores to remember it's been passed
	local _funcname_="$1"

	local params=( "$@" )               ## array containing all params passed here
	local tmpfile="/dev/shm/$RANDOM"    ## temporary file
	local content                       ## content of the temporary file
	local regex                         ## regular expression

	# Shift the first param (which is the name of the function)
	unset params[0]

	# WORKING ON THE TEMPORARY FILE:
	content="#!/bin/bash\n\n"

	# Write the params array
	content="${content}params=(\n"

	regex="\s+"
	for param in "${params[@]}"
	do
		if [[ "$param" =~ $regex ]]
			then
				content="${content}\t\"${param}\"\n"
			else
				content="${content}\t${param}\n"
		fi
	done

	content="$content)\n"
	echo -e "$content" > "$tmpfile"

	# Append the function source
	echo "#$( type "$_funcname_" )" >> "$tmpfile"

	# Append the call to the function
	echo -e "\n$_funcname_ \"\${params[@]}\"\n" >> "$tmpfile"
	sudo bash "$tmpfile"
	rm "$tmpfile"
} # }}}

# Simplify searching for keyword in current dir
findhere() { # {{{
	find . -iname "*$1*" "${@:2}"
} # }}}

# Delete files with patern in current dir
findremove() { # {{{
	local REPLY
	find . -iname "*$1*"
	read -r -n 1 -p "Remove these files? [y/n]: " REPLY
	case "$REPLY" in
		[yY])       echo; find . -iname "*$1*" -exec rm -r "{}" \; ;;
		*)          echo -e "\nNothing deleted." ;;
	esac
} # }}}

delete_older_than_xdays() { # {{{
	if [ $# -eq 0 ] ; then
		echo 'delete_older_than_xdays N_DAYS [path]'
	else
		if [ $# -ne 1 ] ; then
			find . -mtime +$1 -delete
		else
			find "$2" -mtime +$1 -delete
		fi
	fi
} # }}}

# Simplify searching for keyword in current dir, and allow to pass more parameters to grep
grephere() { # {{{
	grep -e "$1" "${@:2}" -d recurse .
} # }}}

remove-special-chars-from-name() { # {{{
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
} # }}}

# preview markdown files as a man page
md() { # {{{
	pandoc -sf markdown -t man "$1" | man -l -
} # }}}

# Extract files
extract () { # {{{
	local f
	for f in "${@}" ; do
		echo extracting $f
		if [ -f "$f" ] ; then
			case "$f" in
				*.tar.bz2)   echo "tar xjf $f"  && tar xjf "$f"             ;;
				*.tar.gz)    echo "tar xzf $f"  && tar xzf "$f"             ;;
				*.tar.xz)    echo "tar xJf $f"  && gunzip "$f"              ;;
				*.bz1)       echo "bunzip2 $f"  && bunzip2 "$f"             ;;
				*.rar)       echo "unrar e $f"  && unrar x "$f"             ;;
				*.gz)        echo "gunzip $f"  && gunzip "$f"               ;;
				*.tar)       echo "tar xf $f"  && tar xf "$f"               ;;
				*.tbz2)      echo "tar xjf $f"  && tar xjf "$f"             ;;
				*.tgz)       echo "tar xzf $f"  && tar xzf "$f"             ;;
				*.zip)       echo "unzip $f"  && unzip "$f"                 ;;
				*.Z)         echo "uncompress $f"  && uncompress "$f"       ;;
				*.7z)        echo "7z x $f"  && 7z x "$f"                   ;;
				*)           echo "'$f' cannot be extracted via extract()"  ;;
			esac
		else
			echo "'$f' is not a valid file"
		fi
	done
}

# i hate typing extract...
alias un=extract

# }}}

# copy files into clipboard with mime type
cinf() { # {{{
	if [[ $# == 0 ]]; then
		xargs -d '\n' realpath | sed 's/.*/file:\/\/&/' | xclip -in -selection clipboard -t text/uri-list
	else
		printf "%s\n" "${@}" | xargs -d '\n' realpath | sed 's/.*/file:\/\/&/' | xclip -in -selection clipboard -t text/uri-list
	fi
} # }}}

# find process by name
psgrep() { # {{{
	local list=$(ps -ef)
	echo -e "$list" | head -n1
	echo -e "$list" | grep -i $1 --color=always | grep -v grep
} # }}}

memhogs () { # {{{
	local TR=`free|grep Mem:|awk '{print $2}'`
	ps axo rss,comm,pid | awk -v tr=$TR '{proc_list[$2]+=$1;} END {for (proc in proc_list) {proc_pct=(proc_list[proc]/tr)*100; printf("%d\t%-16s\t%0.2f%%\n",proc_list[proc],proc,proc_pct);}}' | sort -rn | head -n 10
} # }}}

psmem () { # {{{
	# not working properly
	[[ $# -eq 0 ]] && { echo "Give some process names to search for" ; return 1; }
	local PROCNAME="$@";
	echo $PROCNAME IS USING \
	$(
		echo "scale=4; ($( ps axo rss,comm | grep $PROCNAME | awk '{ TOTAL += $1 } END { print TOTAL }' )/$( free | head -n 2 | tail -n 1 | awk '{ print $2 }' ))*100" | bc
	)% of system RAM;
} # }}}

lfcd () { # {{{
	TMPFILE=$(mktemp /tmp/lfcd-XXXXXX)
	command lf -print-last-dir $@ > $TMPFILE
	cd $(cat $TMPFILE)
	rm $TMPFILE
}
# alias lf=lfcd
# }}}

history-clean() { # {{{
	local pattern="^bb\|^cd\|^ls\|^mv\|^rm\|^ln\|^wc\|^kill\|^vim\|^echo\|^mkdir\|^du\|^df\|^ll\|^diff\|^delta\|^grep\|^eval --\|^chmod\|^touch\|^type\|^lf\|^cat\|^gunzip\|^gzip\|^tar\|^un \|^unzip\|^\.\/\|^sudo cp\|^sudo rm\|^sudo apt list\|^file^\|^less\|^cout\|^cin\|^gd\|^git checkout\|^git diff\|^git show\|^git branch\|^git restore\|^yarn test\|^yarn start\|^dolphin\|^vlc\|^python\|^batcat\|^bat\|^ping"
	sed "/${pattern}/d" -i ~/.bash_history
	sed 's/\s\+$//' -i ~/.bash_history # strip trailing white spaces
}
# }}}

ssh.localhost.run() { # {{{
	local PORT=${1:-8000}
	echo -e "\033[1;33mForwarding port on localhost: ${PORT}\033[m"
	ssh -R 80:localhost:${PORT} localhost.run -- --no-inject-http-proxy-headers 2>&1 | grep https.*life
} # }}}

# GIT
# =========

# delete files from cache
git-delete-cached() { # {{{
	git filter-branch --force --index-filter "git rm --cached --ignore-unmatch $@" --prune-empty --tag-name-filter cat -- --all
} # }}}

# FZF FUNCTIONS
# ==================================

# Select and load a conda environment
conda-envfzf() { # {{{
	local env=$(conda env list | grep "^#\|^$" -v | fzf --height 5 --reverse | awk "{print \$1}")
	if [ ! -z $env ] ; then
		conda activate $env
	fi
} # }}}

# activate a virtual environment
activate() { # {{{
	local path=${1:-'.'}
	local venv_file
	if [ $# -eq 0 ] ; then
		venv_file=$(find . -regex '.*/bin/activate$' | fzf --height 5 --reverse)
	else
		venv_file=$(find $path -regex '.*/bin/activate$')
	fi

	if [ -f $venv_file ] ; then
		echo -e "Activating virtual environment: \033[1;35m$venv_file\033[m"
		source $venv_file
	fi
} # }}}

# OTHERS
# ==================================

# fork to the background silently and send its output to the /dev/null
# NOTES: generic form #>/dev/null (# is 1 by default)
#       2>&-            ---->       #>&-   (close fd)
#       |&              ---->       2>&1
#       &>/dev/null     ---->       1>/dev/null 2>&1
ds() { # {{{
	echo "$@ |& > /dev/null &"
	"$@" |& > /dev/null &
} # }}}

# Use -p to make prompt changes permanent on .bashrc
prompt() { # {{{
	local bashrc=$([[ -L "$HOME/.bashrc" ]] && echo `file "$HOME/.bashrc" | cut -d' ' -f5` || echo "$HOME/.bashrc")
	if [ -f ~/.bash/prompts/prompt_${1}.sh ]; then
		[[ ! -z $2 ]] && [[ $2 == "-p" ]] && sed -i "s/prompt_[0-9]\.sh[^\ \n]*/prompt_${1}\.sh/" $bashrc || echo "Use -p to make changes permanent on .bashrc";
		echo "Sourcing ~/.bash/prompts/prompt_${1}.sh"
		source ~/.bash/prompts/prompt_${1}.sh
	fi
} # }}}

# Display unicode chars
unicode() { # {{{
	local a b c
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
} # }}}

# Function to display terminal colors. $1 -> (1 - simple, 2 - with numbers, 3 - 256 colors)
colors() { # {{{
	local i FGs FG column
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
} # }}}

# Check weather
weather() { #  {{{
	curl wttr.in/$1
}
weather2() {
	curl v2.wttr.in/$1
} # }}}

# generate qr code
generate_qr() { # {{{
	echo "$1" | curl -F-=\<- qrenco.de
} # }}}
