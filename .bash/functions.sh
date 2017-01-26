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

# Extract files
extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   echo "tar xjf $1"  && tar xjf $1        ;;
        *.tar.gz)    echo "tar xzf $1"  && tar xzf $1        ;;
        *.bz2)       echo "bunzip2 $1"  && bunzip2 $1        ;;
        *.rar)       echo "unrar e $1"  && unrar e $1        ;;
        *.gz)        echo "gunzip $1"  && gunzip $1          ;;
        *.tar)       echo "tar xf $1"  && tar xf $1          ;;
        *.tbz2)      echo "tar xjf $1"  && tar xjf $1        ;;
        *.tgz)       echo "tar xzf $1"  && tar xzf $1        ;;
        *.zip)       echo "unzip $1"  && unzip $1            ;;
        *.Z)         echo "uncompress $1"  && uncompress $1  ;;
        *.7z)        echo "7z x $1"  && 7z x $1              ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# record desktop
record() {
	local x
	local y
	x=$(xrandr | grep '*' -m1 | cut -d' ' -f4 | cut -d'x' -f1)
	y=$(xrandr | grep '*' -m1 | cut -d' ' -f4 | cut -d'x' -f2)
	if [ $1 == "1" ]; then
		recordmydesktop --width $x --height $y "${@:2}"
	else
		recordmydesktop -x $x --width $x --height $y "${@:2}"
	fi
}





# ==================================
# ----------------------------------
# -------------ALIASES--------------
# ----------------------------------
# ==================================

# find process by name
psgrep() {
	ps -aux | grep $1 --color=always | grep -v grep
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
		[[ ! -z $2 ]] && [[ $2 == "-p" ]] && sed -i "s/prompt_[0-9]\.sh[^\ \n]*/prompt_${1}\.sh/" $bashrc;
		echo "Sourcing ~/.bash/prompts/prompt_${1}.sh"
		source ~/.bash/prompts/prompt_${1}.sh
	fi
}

# Define function to display terminal colors
colors() {
	local T
	T='gYw'
	echo -e "\n                 40m     41m     42m     43m	 44m     45m     46m     47m";

	for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
		'1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
			'  36m' '1;36m' '  37m' '1;37m';
		do FG=${FGs// /}
		echo -en " $FGs \033[$FG  $T  "
			for BG in 40m 41m 42m 43m 44m 45m 46m 47m;
		do echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m";
		done
		echo;
	done
	echo
}

colorsplus() {
	for i in $(seq 0 4 255); do
		for j in $(seq $i $(expr $i + 3)); do
			for k in $(seq 1 $(expr 3 - ${#j})); do
				printf " "
			done
			echo -en "\033[38;5;${j}mcolour${j}"
			[[ $(expr $j % 4) != 3 ]] && echo -n "    "
		done
		echo "\n"
	done
}
