#!/bin/bash

set -e

if [[ ! -d styles ]] ; then
	echo "Run from parent directory './install/monochrome.sh'"
	exit
fi

if hash nativefier &>/dev/null ; then
	mkdir -p /tmp/monochrome
	curl "https://monochrome.tf/assets/appicon.png" > /tmp/monochrome/monochrome.png
	nativefier --icon /tmp/monochrome/monochrome.png --name monochrome --single-instance monochrome.tf /tmp/monochrome
	if [ -d "/opt/monochrome" ] ; then
		echo "Deleting previous Monochrome installation"
		sudo rm -r "/opt/monochrome"
	fi
	sudo mv /tmp/monochrome/monochrome-linux-x64 /opt/monochrome
	rm /tmp/monochrome -r
	sudo tee /usr/share/applications/monochrome.desktop >/dev/null <<EOF
[Desktop Entry]
Name=Monochrome
Comment=Monochrome
Exec=/opt/monochrome/monochrome --no-sandbox
Icon=/opt/monochrome/resources/app/icon.png
Terminal=false
Type=Application
Categories=Music
EOF
	echo "Monochrome installed successfully"
else
	echo -e '\033[31mnativefier is not installed\033[m'
fi
