#!/bin/bash

set -e

if [[ ! -d styles ]] ; then
	echo "Run from parent directory './install/patch/slack.sh'"
	exit
fi

mkdir /tmp/slack-setup-hack
JS=$(cat "styles/slack-gruvbox.js")
npx asar extract /usr/lib/slack/resources/app.asar /tmp/slack-setup-hack/
sed -i '/EXIMUS PATCH/d' /tmp/slack-setup-hack/dist/preload.bundle.js
echo $JS >> /tmp/slack-setup-hack/dist/preload.bundle.js
npx asar pack /tmp/slack-setup-hack/ /tmp/slack-setup-hack/app.asar
sudo mv /tmp/slack-setup-hack/app.asar /usr/lib/slack/resources/app.asar
echo "Slack setup successfully"
rm -r /tmp/slack-setup-hack

