# vi: tabstop=4

shopt -s expand_aliases

# enable color support of ls
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
fi

alias list-functions='select i in `grep -P "[a-zA-Z0-9_\-]+(?=\(\))" -o $HOME/.bash/functions.sh`; do declare -f $i; break; done'

# more ls aliases
alias ll='ls -lF'
alias la='ls -AF'
alias lla='ls -lFA'
alias l.='ls -Fd .*'

alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'

alias dirs='dirs -v'

# Utilities
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias pacman='pacman --color=auto'
alias less='less -MRix4'
alias gdb='gdb -q'
alias dd='dd status=progress'
alias alert="echo -ne '\a' && paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
alias perl-regex='perl -p -i -e'
alias grep-bin='grep -oUaP' # pattern like: "\xde\xad"
alias htop-mem='htop --sort-key=PERCENT_MEM'
alias htop-cpu='htop --sort-key=PERCENT_CPU'
alias fzf='fzf --ansi --reverse --height ~20'
alias bat='batcat'

# Clipboard
alias cin='xclip -r -in -selection clipboard'
alias cout='xclip -r -out -selection clipboard'

alias list-open-ports='sudo netstat -tulpn | grep LISTEN'
alias ipad="ip -brief -f inet address | fzf +m --reverse --height 10 | awk '{gsub(\"/.*\",\"\",\$3);print\$3}' | tee /dev/tty | xclip -r -in -selection clipboard"

# git, the quoting hack is needed to use nested single quotes
alias git-lfs='git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -10 | awk '"'"'{print$1}'"'"')"'
alias gs='git status'
alias gp='git push'
alias gpf='git push --force'
alias gpd='git push --delete'
alias gc='git commit'
alias gca='git commit --amend'
alias ga='git add .'
alias gl='git lol' # because my own alias is too much typing
alias gla='git lol --all'
alias gd='git diff'

# list vm images
alias vml="virsh vol-list --pool default --details | tail -n +3 | head -n-1 | awk 'BEGIN {print \"Name Allocation Capacity\"}{print\$1\" \"\$6\".\"\$7\" \"\$4\".\"\$5}' | column -t"
# connect to a qemu virtual machine console
alias vmv="virsh list --name | head -n-1 | fzf --prompt='View vm > ' | xargs -r virt-manager -c qemu:///system --show-domain-console || :"
# delete qemu image
alias vmd="virsh vol-list --pool default --details | tail -n +3 | head -n-1 | awk '{print\$1\" \"\$6\" \"\$7}' | column -t | fzf --prompt='Delete image > ' | awk '{print\$1}' | xargs -r virsh vol-delete --pool default || :"

# URL encoding-decoding
alias urlencode='python3 -c "import sys,urllib.parse;print(urllib.parse.quote(sys.stdin.read()));"'
alias urldecode='python3 -c "import sys,urllib.parse;print(urllib.parse.unquote(sys.stdin.read()));"'

# vagrant alias
alias vu="vagrant up"
alias vs="vagrant status"
alias vh="vagrant halt"
alias vrdp="vagrant rdp -- /cert:ignore /dynamic-resolution +clipboard +drive:smbfolder,$PWD"
alias vsh="vagrant ssh"
alias vsh-tmux="vagrant ssh -- -t tmux new-session -A -s vm"

# SSH
alias load-keychain='[[ -f "${HOME}/.ssh/id_rsa" ]] && keychain "${HOME}/.ssh/id_rsa" --quiet && source "${HOME}/.keychain/${HOSTNAME}-sh"'

# i keep forgetting this...
alias man-pipes='echo "Generic form #>/dev/null (# is 1 by default) or #>&# to send one fd to another"; echo "  2>&-        ----> #>&-  (close fd)"; echo "  |&          ----> 2>&1 |"; echo "  &>/dev/null ----> 1>/dev/null 2>&1"'

# wget to download directory, use -P to specify output directory
# -k option might give memory issues when continuing (-c) the download of large files but without it wget wont check for partially downlaoded files and will assume they are downloaded if they exist
alias wget-directory='wget -r -np -nc -nd -k'

alias pip-upgrade='pip3 list --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 sudo pip3 install -U'

alias ffuf='ffuf -c -ic'
alias py='ipython3'

# KALI
# start konsole emulator attached to remote tmux session
alias cutter='LIBGL_ALWAYS_INDIRECT=1 /vagrant/tools/Cutter-v2.2.0-Linux-x86_64.AppImage'
alias ghidra-server='sudo /usr/share/ghidra/server/ghidraSvr'
alias ghidra-admin='sudo /usr/share/ghidra/server/svrAdmin'
alias ysoserial='java -jar --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.runtime=ALL-UNNAMED --add-opens java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED /vagrant/tools/ysoserial-all.jar'

# PLEX
# Add this to sudoers or a file in sudoers.d
#      %eximus ALL= NOPASSWD: /bin/systemctl start plexmediaserver.service
#      %eximus ALL= NOPASSWD: /bin/systemctl stop plexmediaserver.service
#      %eximus ALL= NOPASSWD: /bin/systemctl restart plexmediaserver.service
# alias plex='sudo systemctl start plexmediaserver.service'
# alias plex-status='systemctl status plexmediaserver.service'
# alias plex-stop='sudo systemctl stop plexmediaserver.service'
# alias plex-restart='sudo systemctl restart plexmediaserver.service'

# Map
alias map-view='telnet mapscii.me'

alias random-commit='git commit -m "$(curl -Lsk whatthecommit.com/index.txt)"'
