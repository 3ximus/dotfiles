#!/bin/sh

# Clear the last preview (if any)
$HOME/.config/lf/image clear

# Calculate where the image should be placed on the screen.
num=$(printf "%0.f\n" "`echo "$(tput cols) / 2" | bc`")
numb=$(printf "%0.f\n" "`echo "$(tput cols) - $num - 1" | bc`")
numc=$(printf "%0.f\n" "`echo "$(tput lines) - 2" | bc`")

case "$1" in
	*.tgz|*.tar.gz) tar tzf "$1";;
	*.tar.bz2|*.tbz2) tar tjf "$1";;
	*.tar.txz|*.txz) xz --list "$1";;
	*.tar) tar tf "$1";;
	*.zip|*.jar|*.war|*.ear|*.oxt) unzip -l "$1";;
	*.rar) unrar l "$1";;
	*.7z) 7z l "$1";;
	*.[1-8]) man "$1" | col -b ;;
	*.o) nm "$1" | less ;;
	*.torrent) transmission-show "$1";;
	*.iso) iso-info --no-header -l "$1";;
	*odt,*.ods,*.odp,*.sxw) odt2txt "$1";;
	*.doc) catdoc "$1" ;;
	*.docx) docx2txt < "$1";;
	*.csv) cat "$1" | sed s/,/\\n/g ;;
	*) batcat --color always --decorations never "$1" || cat "$1";;
esac
