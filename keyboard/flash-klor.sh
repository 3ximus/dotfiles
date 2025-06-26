#!/bin/bash

# Script to flash my corne

if [[ ! -d keyboard ]] ; then
	echo "Run from parent directory './keyboard/flash-klor.sh'"
	exit
fi

echo Flashing ${firmware}...

if command -v qmk 2>&1 >/dev/null; then
	kb="klor/2040"
	km="3ximus"
	qmkhome=$(qmk config | sed -n '/home/s/.*=\(.*\)/\1/p')
	uf2file="$(qmk compile -kb $kb -km $km -n 2>&1 | tr ' ' '\n' | sed -n '/TARGET/s/TARGET=//p').uf2"
	echo "Hold the reset button and mount the device when prompted."
	read -p "Press any key to continue..." answer
	# sudo mount -o defaults,uid=1000,gid=1000 /dev/sdb1 /media/eximus/RPI
	qmk flash -kb $kb -km $km
	firmware=$(find "$qmkhome" -maxdepth 1 -name "$uf2file")
	if [ -z $firmware ]; then
		# save the compiled file to this repo
		cp "$firmware" ./keyboard/
	fi
else
	echo qmk needs to be installed
fi

