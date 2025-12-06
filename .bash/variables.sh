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

# pnpm
if command -v pnpm >/dev/null ; then
	export PNPM_HOME="/home/eximus/.local/share/pnpm"
	case ":$PATH:" in
		*":$PNPM_HOME:"*) ;;
		*) export PATH="$PNPM_HOME:$PATH" ;;
	esac
fi

# fzf CTRL_T options
export FZF_COMPLETION_OPTS="--preview '[ -f {} ] && { if hash batcat &>/dev/null ; then batcat --color=always --style=changes {} ; else file {} ; fi } '"
# export FZF_DEFAULT_OPTS='--color=spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'
export FZF_DEFAULT_OPTS='--color=spinner:1,hl:8,fg:15,header:7,info:3,pointer:1,marker:1,fg+:15,prompt:6,hl+:1'
export FZF_CTRL_T_OPTS="$FZF_COMPLETION_OPTS"
# change fzf-marks paste binding
export FZF_MARKS_PASTE="ctrl-l"

# batcat
export BAT_THEME="gruvbox-dark"
export BAT_PAGER=""
export BAT_STYLE="numbers"

