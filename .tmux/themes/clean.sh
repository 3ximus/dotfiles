# Clean Theme, not actually powerline...


# Format: segment_name background_color foreground_color [non_default_separator]

if [ -z $TMUX_POWERLINE_LEFT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_LEFT_STATUS_SEGMENTS=(
		"tmux_session_info 0 7 " \
		#"hostname 0 2" \
		#"lan_ip 0 7 ${TMUX_POWERLINE_SEPARATOR_RIGHT_THIN}" \
		#"wan_ip 0 7" \
		#"ifstat_sys 12 7" \
	)
fi

if [ -z $TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS ]; then
	TMUX_POWERLINE_RIGHT_STATUS_SEGMENTS=(
		#"cpu 0 7" \
		#"load 7 0" \
		#"tmux_mem_cpu_load 234 136" \
		"battery 4 0 none" \
		"uptime default 7 none"
		"date_day default 7 none" \
		"date default 7 none" \
		#"time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
		"time default 3 none" \
		#"utc_time 235 136 ${TMUX_POWERLINE_SEPARATOR_LEFT_THIN}" \
	)
fi
