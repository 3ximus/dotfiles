#!/bin/sh
sleep 6
kwriteconfig5 --file /home/eximus/.config/kwinrc --group Windows --key BorderlessMaximizedWindows true
qdbus org.kde.KWin /KWin reconfigure
