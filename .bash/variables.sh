# ==============
#   VARIABLES
# ==============

export EDITOR=vim

export COLORTERM=truecolor

# add customs scripts
export PATH=$PATH:$HOME/.bash/scripts:$HOME/.local/bin

# go
command -v go >/dev/null && export PATH=$PATH:$HOME/go/bin

# cargo
command -v cargo >/dev/null && export PATH=$PATH:$HOME/.cargo/bin

# bun
command -v bun >/dev/null && export PATH=$PATH:$HOME/.bun/bin

# fzf CTRL_T options
export FZF_COMPLETION_OPTS="--preview '[ -f {} ] && { if hash batcat &>/dev/null ; then batcat --color=always --style=changes {} ; else file {} ; fi } '"
export FZF_CTRL_T_OPTS="$FZF_COMPLETION_OPTS"
# change fzf-marks paste binding
export FZF_MARKS_PASTE="ctrl-l"

# batcat
export BAT_THEME="gruvbox-dark"

