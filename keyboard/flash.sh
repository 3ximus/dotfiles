#!/bin/bash

# Script to flash my corne

if [[ ! -d keyboard ]] ; then
	echo "Run from parent directory './keyboard/flash.sh'"
	exit
fi

select firmware in ./keyboard/*.hex ; do break; done

# ask for sudo password first
sudo echo Flashing ${firmware}...
sudo echo Sleeping for 5 seconds. Hit the reset button now!
sleep 5

if sudo dfu-programmer atmega32u4 get ; then
	sudo dfu-programmer atmega32u4 erase
	sudo dfu-programmer atmega32u4 flash $firmware
	sudo dfu-programmer atmega32u4 reset
fi
