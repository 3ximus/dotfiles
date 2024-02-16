#!/bin/bash

set -e

if [[ ! -d styles ]] ; then
	echo "Run from parent directory './install/patch/slack.sh'"
	exit
fi

menuBarPatchFile="/opt/Postman/app/resources/app/services/windowManager.js"
if [[ -f $menuBarPatchFile  ]] ; then
	ln=$(grep -n isDarwin $menuBarPatchFile | tail -n1 | cut -d: -f1)
	inject="if (process.platform === 'linux') { Object.assign(browserWindowOptions, { autoHideMenuBar: true });}"
	sed -i "$((ln -2)) a $inject" $menuBarPatchFile
fi

JS=$(cat "styles/postman-gruvbox.js")
sed -i '/EXIMUS PATCH/d' /opt/Postman/app/resources/app/preload/desktop/index.js
echo $JS >> /opt/Postman/app/resources/app/preload/desktop/index.js
echo "Postman patched successfully"

