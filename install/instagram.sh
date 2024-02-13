#!/bin/bash

set -e

if [[ ! -d styles ]] ; then
	echo "Run from parent directory './install/instagram.sh'"
	exit
fi

if hash nativefier &>/dev/null ; then
	echo "Choose instagram theme:"
	select theme_path in ../styles/*.css ; do break; done
	nativefier --inject $theme_path --icon "${DATA_PATH}/icons/instagram.png" --name instagram --counter --single-instance instagram.com /tmp/instagram
	if [ -d "/opt/instagram" ] ; then
		echo "Deleting previous Instagram installation"
		sudo rm -r "/opt/instagram"
	fi
	sudo mv /tmp/instagram/instagram* /opt/instagram
	rm /tmp/instagram -r
	echo "Instagram installed successfully"
else
	echo -e '\033[31mnativefier is not installed\033[m'
fi
