export SSH_ASKPASS="/usr/bin/ksshaskpass"

if [ -f "${HOME}/.ssh/id_rsa" ]; then
	keychain "${HOME}/.ssh/id_rsa" --quiet
	source "${HOME}/.keychain/${HOSTNAME}-sh"
fi

if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi
