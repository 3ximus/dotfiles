#!/bin/bash

set -e

if [[ ! -d styles ]] ; then
	echo "Run from parent directory './install/patch/slack.sh'"
	exit
fi

# TODO add this patch https://github.com/postmanlabs/postman-app-support/issues/11197#issuecomment-1917636907

JS=$(cat "styles/postman-gruvbox.js")
sed -i '/EXIMUS PATCH/d' /opt/Postman/app/resources/app/preload/desktop/index.js
echo $JS >> /opt/Postman/app/resources/app/preload/desktop/index.js
echo "Postman patched successfully"

