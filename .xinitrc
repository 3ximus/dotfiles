# load resources
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

# keyboard layout
#  - if launching .xinit from sddm with xinit-xsession then this is set in the file /etc/X11/xorg.conf.d/00-keyboard.conf
setxkbmap pt -variant nodeadkeys
xset r rate 200 40

# set background
feh --bg-fill '/home/eximus/Pictures/tobias-van-schneider-100597-unsplash.jpg' &

# compositors are blot
compton &

# hide cursor
unclutter &

# configure touchpad
if [[ $(hostname) == 'mercury' ]]; then
	xinput --set-prop 'ETPS/2 Elantech Touchpad' "libinput Tapping Enabled" 1 &
	xinput --set-prop 'ETPS/2 Elantech Touchpad' "libinput Natural Scrolling Enabled" 1 &
fi

# disable display power management
xset -dpms &
xset s off &

xsetroot -cursor_name left_ptr

# start hotkey daemon
sxhkd &

# start session
urxvt -e /usr/bin/tmux &
exec bspwm
