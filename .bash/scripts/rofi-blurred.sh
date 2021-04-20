#!/bin/bash

# Wrapper to run rofi with blurred background

# /usr/bin/rofi -font 'Droid Sans Mono for Powerline 15' $HOME/.local/share/icons/Papirus-Dark/ -theme $HOME/.config/rofi/gruvbox-rofi-theme.rasi $@ &
/usr/bin/rofi -font 'TerminessTTF Nerd Font Mono 20' $@ &

# this will enable blur behind rofi
# c=0
# while ! xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id $(xdotool search -class 'rofi') ; do
# 	sleep .1
# 	c=$((c+1))
# 	[[ c = 50 ]] && exit; # stop script window didn't appear after 5 seconds
# done

