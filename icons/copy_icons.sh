#!/bin/sh

if [ -z $1 ] ; then
	PAPIRUS=/usr/share/icons/Papirus-Dark/
else
	PAPIRUS=$1
fi
echo -e "Copying \033[33mNormal Icons\033[m icons"
sudo cp $PWD/*.svg $PAPIRUS/16x16/apps/

echo -e "Copying \033[35mDiscord\033[m icons"
if [[ -d /opt/discord ]]; then
	sudo cp $PWD/discord.png /opt/discord/
	if hash asar &>/dev/null ; then
		TMPDIR="/tmp/discord_core"
		mkdir $TMPDIR
		echo "> Unziping Contents..."
		unzip /opt/discord/resources/bootstrap/discord_desktop_core.zip -d $TMPDIR
		echo "> Extracting asar..."
		asar extract $TMPDIR/core.asar $TMPDIR/core
		cp $PWD/discord-tray/tray{,-unread}.png $TMPDIR/core/app/images/systemtray/linux/
		echo "> Repacking files..."
		asar pack $TMPDIR/core $TMPDIR/core.asar && rm -r $TMPDIR/core
		pushd $TMPDIR && zip discord_desktop_core.zip * && popd
		echo "> Replacing files..."
		sudo mv $TMPDIR/discord_desktop_core.zip /opt/discord/resources/bootstrap/
		rm -r $TMPDIR
	else
		echo -e "\033[31mNot able to install discord tray icons since asar is not installed\033[m"
	fi


fi

echo -e "Copying \033[32mWhatsApp\033[m icons"
[[ -d /opt/whatsapp-web/resources/app ]] && cp $PWD/whatsapp.png /opt/whatsapp-web/resources/app/icon.png



