#!/bin/sh

# Blurs area behind a window on plasma
# if argument is given it searches for that window and gives a menu to choose, otherwise it will be interactive

if [ -z $1 ]; then
	xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $(xwininfo | awk '/Window\ id/ {print $4;}')
else
	list=( `xdotool search $1 2>/dev/null` )
	for i in $(seq 0 $((${#list[@]}-1))); do list[$i]="${list[$i]} - `xdotool getwindowname ${list[$i]}`"; done
	select window in "${list[@]}"; do
		xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id ${window/[^0-9]*/}
		break
	done
fi
