#!/bin/bash

set -e

if [[ ! -d styles ]] ; then
	echo "Run from parent directory './install/whatsapp.sh'"
	exit
fi

if hash nativefier &>/dev/null ; then
	echo "Choose whatsapp theme:"
	select theme_path in styles/*.css ; do break; done
	echo "if ('serviceWorker' in navigator) {caches.keys().then(function (cacheNames) {cacheNames.forEach(function (cacheName) {caches.delete(cacheName);});});}" >/tmp/whatsapp-inject.js
	# Ctrl+k functionality
	echo "document.addEventListener('keydown', (event) => {if(event.ctrlKey && event.keyCode == 75) document.querySelector('div[data-lexical-editor=\"true\"]').focus()});" >>/tmp/whatsapp-inject.js
	nativefier --inject $theme_path --inject /tmp/whatsapp-inject.js --icon "./icons/whatsapp.png" --name whatsapp --counter --single-instance --user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0" web.whatsapp.com /tmp/whatsapp
	if [ -d "/opt/whatsapp" ] ; then
		echo "Deleting previous WhatsApp installation"
		sudo rm -r "/opt/whatsapp"
	fi
	sudo mv /tmp/whatsapp/whatsapp* /opt/whatsapp
	rm /tmp/whatsapp -r
	echo "Whatsapp installed successfully"
else
	echo -e '\033[31mnativefier is not installed\033[m'
fi
