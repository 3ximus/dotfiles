#!/bin/bash
# For this to work you will need oomox instaled (if you use the repo "https://github.com/actionless/oomox" run ./oomoxify.sh instead of oomoxify-cli)
[[ -f $HOME/.config/oomox/colors/gruvbox-spotify ]] || { mkdir -p $HOME/.config/oomox/colors/ && cp $PWD/gruvbox-spotify $HOME/.config/oomox/colors/gruvbox-spotify ; }
oomoxify-cli -s /usr/share/spotify/Apps/ $HOME/.config/oomox/colors/gruvbox-spotify -f "Source Code Pro for Powerline" -w 
echo " > Replacing foreground 1"
sudo sed -i 's/#fffffd/#fbf1c7/I' /usr/share/spotify/Apps/*.spa
echo " > Replacing foreground 2"
sudo sed -i 's/#b3b3b3/#a89984/I' /usr/share/spotify/Apps/*.spa
echo " > Replacing Background"
sudo sed -i 's/#181818/#282828/I' /usr/share/spotify/Apps/*.spa

