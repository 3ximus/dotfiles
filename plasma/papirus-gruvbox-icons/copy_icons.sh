#!/bin/sh

if [ -z $1 ] ; then
	PAPIRUS=/usr/share/icons/Papirus-Dark/
else
	PAPIRUS=$1
fi
cp $PWD/*.svg $PAPIRUS/16x16/apps/

[[ -d /opt/discord ]] && cp $PWD/discord.png /opt/discord/
