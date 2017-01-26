export SSH_ASKPASS="/usr/bin/ksshaskpass"

keychain ~/.ssh/id_rsa -quiet
. .keychain/$HOSTNAME-sh

source ~/.bashrc
