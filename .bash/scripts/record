#!/bin/bash

# Wrapper to record screen into a video or gif

# PRINT HELP
if [[ $# -eq 0 || "$1" = "help" || "$1" = "-help" || "$1" = "--help" || "$1" = "-h" ]]; then
	echo -e "Usage record [OPTIONS] FILE

Options:
    -g, --gif     Record Gif. More options for byzanz-record: (see man page)
        -d, --duration=SECS
               Duration of animation (default: 10 seconds)

        -e, --exec=COMMAND
               Instead of specifying the duration of the animation, execute the given COMMAND
                and record until the  com‐mand exits. This is useful both for benchmarking and
                to use more complex ways to stop the recording, like writing scripts that listen on dbus.

        --delay=SECS
               Delay before start (default: 1 second)

    -v, --video  Record Video (for options see man recordmydesktop)
Aditional arguments can be given to either option and they will be passed onto their repective programs.

NOTE: For large areas/duration of recording gif its better to record video and convert to GIF later with ffmpeg." && exit 0
fi

# Check if import command is available do interactivly determine screen region
if ! hash import 2>/dev/null ; then
	echo -e "\e[1;31mImagemagik not installed, cannot get region interactively\e[0m"
	exit 1
fi

echo "Select region."
values=($(import -verbose /tmp/tmprec_region 2>&1| awk -F'[ +x]' '{ print $3, $4, $7, $8}'))

# in case selected region is 1 pixel or outside border import will print some [[:alpha:]] chars (hopefully every time)
echo $values
if [ ! "${#values[@]}" == 4 ] || echo "${values[@]}" | grep "[[:alpha:]]" >/dev/null ; then
	echo -e "\e[1;31mInvalid Region\e[0m"
	exit 1
fi

# values contains:
#   ${values[0]}  -->   width
#   ${values[1]}  -->   height
#   ${values[2]}  -->   x coord
#   ${values[3]}  -->   y coord

# GIFS
if [ "$1" = "-g" -o "$1" = "--gif" ]; then
# Check if byzanz is available
	if ! hash byzanz-record 2>/dev/null ; then
		echo -e "\e[1;31mbyzanz-record not installed, cannot record to GIF\e[0m"
		exit 1
	fi
	echo -e "Recording GIF on region:\nWidth:${values[0]}   Height:${values[1]}   x:${values[2]}   y:${values[3]}"
	[[ $# == 1 ]] && moreargs="out.gif" || moreargs="${@:2}"
	byzanz-record --width=${values[0]} --height=${values[1]} --x=${values[2]} --y=${values[3]} $moreargs
	exit $?
fi

# VIDEOS
if [ "$1" = "-v" -o "$1" = "--video" ]; then
# Check if byzanz is available
	if ! hash recordmydesktop 2>/dev/null ; then
		echo -e "\e[1;31mrecordmydesktop not installed, cannot record video\e[0m"
		exit 1
	fi
	recordmydesktop --width ${values[0]} --height ${values[1]} -x ${values[2]} -y ${values[3]} "${@:2}"
	exit $?
fi

echo -e "\e[1;31mInvalid Option given\e[0m"
exit 1

