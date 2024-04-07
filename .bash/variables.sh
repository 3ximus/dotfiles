# ==============
#   VARIABLES
# ==============

export EDITOR=vim

export COLORTERM=truecolor

# add customs scripts
export PATH=$HOME/.bash/scripts:$PATH

# go
export PATH=$HOME/go/bin:$PATH

# cargo
export PATH=$HOME/.cargo/bin:$PATH

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# fzf CTRL_T options
export FZF_COMPLETION_OPTS="--preview '[ -f {} ] && { if hash batcat &>/dev/null ; then batcat --color=always --style=header,numbers,changes {} ; else file {} ; fi } '"
export FZF_CTRL_T_OPTS="$FZF_COMPLETION_OPTS"
# change fzf-marks paste binding
export FZF_MARKS_PASTE="ctrl-l"

# batcat
export BAT_THEME="gruvbox-dark"

