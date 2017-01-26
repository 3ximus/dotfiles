#!/bin/sh

lower_color=197
upper_color=41
border_color=235
highlight_color=255
bottom_light=203

cat ~/.bash/greet/eximus_graffiti_smaller.ans |
	sed "s/█/$(echo -e "\033[38;5;${border_color};48;5;${border_color}m&\033[0m")/g
		s/▓/$(echo -e "\033[38;5;${lower_color};48;5;${lower_color}m▓")/g
		s/▒/$(echo -e "\033[38;5;${upper_color};48;5;${upper_color}m▒")/g
		s/a/$(echo -e "\033[38;5;${lower_color};48;5;${upper_color}m░")/g
		s/b/$(echo -e "\033[38;5;${lower_color};48;5;${upper_color}m▒")/g
		s/c/$(echo -e "\033[38;5;${upper_color};48;5;${lower_color}m▒")/g
		s/d/$(echo -e "\033[38;5;${upper_color};48;5;${lower_color}m░")/g
		s/f/$(echo -e "\033[38;5;${bottom_light};48;5;${lower_color}m▒")/g
		s/z/$(echo -e "\033[38;5;${highlight_color};48;5;${highlight_color}m▓")/g
		s/y/$(echo -e "\033[38;5;${highlight_color}m▒")/g
		s/exi/$(echo -e "\033[1;38;5;${upper_color}m&")/g
		s/mus/$(echo -e "\033[1;38;5;${lower_color}m&")/g"

