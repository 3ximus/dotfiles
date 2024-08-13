#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.bash
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_J_COMMAND
# - $FZF_ALT_J_OPTS

__fzf_select__() {
  local path="${1:-.}"
  local query=""

  if [ ! -d ${path/#\~/$HOME} ] ; then
    query=${path##*/}
    path=${path%/*}
  fi

  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L ${path} \
      -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \\( -type d -o -type f -o -type l \\) \
      -a -not -path ${path} -print 2> /dev/null"}"
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-60%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) --query "$query" | while read -r item; do
    printf '%q ' "$item"
  done
  echo
}

if [[ $- =~ i ]]; then
    __fzfcmd() {
      [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
        echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
    }

    __fzf_file_widget__() {
      local line=${READLINE_LINE:0:$READLINE_POINT}
      local path=${line/* /}
      [ ${#path} -gt 0 ] && line=${line::-${#path}}
      local selected="$(__fzf_select__ $path)"
      if [[ -n $selected ]]; then
        READLINE_LINE="${line}$selected${READLINE_LINE:$READLINE_POINT}"
        READLINE_POINT=$(( READLINE_POINT + ${#selected} ))
      fi
    }

    __fzf_cd__() {
      local cmd dir
      cmd="${FZF_ALT_J_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
        -o -type d -print 2> /dev/null | cut -b3-"}"
      dir=$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_J_OPTS" $(__fzfcmd) +m)
      cd "$dir"
    }

    __fzf_rg__() {
      rg --color=always --line-number --no-heading --smart-case "${*:-}" |
        fzf --ansi \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'batcat --color=always {1} --highlight-line {2}' \
          --bind 'enter:become(vim {1} +{2})'
    }

    __fzf_history__() {
      local output
      output=$(
        builtin fc -lnr -2147483648 |
          last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
          FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS +m --read0" $(__fzfcmd) --query "$READLINE_LINE"
      ) || return
      READLINE_LINE=${output#*$'\t'}
      if [ -z "$READLINE_POINT" ]; then
        echo "$READLINE_LINE"
      else
        READLINE_POINT=0x7fffffff
      fi
    }

    if [ "${BASH_VERSINFO[0]}" -ge 4 ]; then
      # CTRL-T - Paste the selected file path into the command line
      bind -m emacs-standard -x '"\C-t": __fzf_file_widget__'
      bind -m vi-command -x '"\C-t": __fzf_file_widget__'
      bind -m vi-insert -x '"\C-t": __fzf_file_widget__'

      # CTRL-R - Paste the selected command from history into the command line
      bind -m emacs-standard -x '"\C-r": __fzf_history__'
      bind -m vi-command -x '"\C-r": __fzf_history__'
      bind -m vi-insert -x '"\C-r": __fzf_history__'
    fi
fi
