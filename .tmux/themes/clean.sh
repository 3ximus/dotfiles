# Clean Theme, not actually powerline...


# Format: segment_name background_color foreground_color separator[none if empty]

if [ -z $TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		"uptime default 7 none"
		"battery default 4,bold none" \
		"date_day default 7 none" \
		"date default 7 none" \
		"time default 14,bold none" \
	)
fi
