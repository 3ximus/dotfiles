#!/bin/bash

set -e

if [[ ! -d styles ]] ; then
	echo "Run from parent directory './install/patch/slack.sh'"
	exit
fi

TMP_DIR=/tmp/slack-setup-patch
mkdir $TMP_DIR
JS=$(cat "styles/slack-gruvbox.js")
npx asar extract /usr/lib/slack/resources/app.asar $TMP_DIR/
sed -i '/EXIMUS PATCH/d' $TMP_DIR/dist/preload.bundle.js
echo "$JS" | tr -d '\n' >> $TMP_DIR/dist/preload.bundle.js
npx asar pack $TMP_DIR/ $TMP_DIR/app.asar
sudo mv $TMP_DIR/app.asar /usr/lib/slack/resources/app.asar
echo "Slack patched successfully"
rm -r $TMP_DIR

