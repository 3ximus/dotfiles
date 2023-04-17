#!/bin/bash
data=$(qdbus --literal org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Metadata | sed 's/.*"xesam:artist"[^"]*"\([^"]*\)".*"xesam:title"[^"]*"\([^"]*\)".*/\2 - \1/' | cut -c -60)
[[ -z $data ]] && echo -n '_' || echo -n "<font size=4 color='#b3deef'>♫</font> ${data} | size=14"
