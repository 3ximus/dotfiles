# ==============
#   VARIABLES
# ==============

export EDITOR=vim

export COLORTERM=truecolor

# add customs scripts
export PATH=$PATH:$HOME/.bash/scripts

# go
export PATH=$PATH:$HOME/go/bin

# cargo
export PATH=$PATH:$HOME/.cargo/bin

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$PATH:$BUN_INSTALL/bin

# fzf CTRL_T options
export FZF_COMPLETION_OPTS="--preview '[ -f {} ] && { if hash batcat &>/dev/null ; then batcat --color=always --style=changes {} ; else file {} ; fi } '"
export FZF_CTRL_T_OPTS="$FZF_COMPLETION_OPTS"
# change fzf-marks paste binding
export FZF_MARKS_PASTE="ctrl-l"

# batcat
export BAT_THEME="gruvbox-dark"

