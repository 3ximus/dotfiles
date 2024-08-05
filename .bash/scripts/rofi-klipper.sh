#!/bin/bash

clipboard-history(){
	for (( i=0; i<20 ; i++ )) ; do
		qdbus org.kde.plasmashell /klipper org.kde.klipper.klipper.getClipboardHistoryItem $i | paste -sd ' ' | cut -c1-80
	done
}

selected=$(clipboard-history | rofi -dmenu -format i -i -p "clipboard")
if [ $? == 0 ] ; then
	qdbus org.kde.plasmashell /klipper org.kde.klipper.klipper.getClipboardHistoryItem $selected \
		| head -c -1 \
		| xargs -0 -IREPLACE qdbus org.kde.plasmashell /klipper org.kde.klipper.klipper.setClipboardContents REPLACE
fi
