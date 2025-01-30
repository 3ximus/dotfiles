#!/bin/bash

# Script to flash my corne

if [[ ! -d keyboard ]] ; then
	echo "Run from parent directory './keyboard/flash.sh'"
	exit
fi

if command -v qmk 2>&1 >/dev/null; then
	kb="crkbd/rev1"
	km="3ximus"
	qmkhome=$(qmk config | sed -n '/home/s/.*=\(.*\)/\1/p')
	hexfile="$(qmk compile -kb $kb -km $km -n 2>&1 | tr ' ' '\n' | sed -n '/TARGET/s/TARGET=//p').hex"
	read -p "Compile firmware (y/n)? " answer
	case ${answer:0:1} in
		y|Y ) qmk compile -kb $kb -km $km ;  ;;
		* ) : ;;
	esac
	firmware=$(find "$qmkhome" -maxdepth 1 -name "$hexfile")
fi

if [ -z $firmware ]; then
	select firmware in ./keyboard/*.hex ; do break; done
else
	# save the compiled file to this repo
	cp "$firmware" ./keyboard/
fi

# ask for sudo password first
echo Flashing ${firmware}...
sudo echo Sleeping for 4 seconds. Hit the reset button now!
sleep 4

if sudo dfu-programmer atmega32u4 get ; then
	sudo dfu-programmer atmega32u4 erase
	sudo dfu-programmer atmega32u4 flash $firmware
	sudo dfu-programmer atmega32u4 reset
fi
