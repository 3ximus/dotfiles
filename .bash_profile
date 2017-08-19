export SSH_ASKPASS="/usr/bin/ksshaskpass"

keychain ~/.ssh/id_rsa --quiet
source "$HOME"/.keychain/"$HOSTNAME"-sh

source ~/.bashrc
