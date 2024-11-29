if &rtp =~ 'fzf.vim' && glob("~/.vim/plugged/fzf.vim/plugin/fzf.vim")!=#""

  function s:FZFViewOpts(opts, width, height)
    if exists('$TMUX')
      let a:opts['tmux'] = '-p'.a:width.'%,'.a:height.'%'
    else
      let a:opts['window'] = { 'width': a:width/100, 'height': a:height/100 , 'border': 'sharp' }
    endif
  endfunction

  " Sink Function Git Edit: {{{
  function s:GitEditFile(mode, commit, file)
    if match(a:mode, 'ctrl-s') == 0
      execute "Gsplit ".a:commit.":".a:file
    elseif match(a:mode, 'ctrl-v') == 0
      execute "Gvsplit ".a:commit.":".a:file
    else
      execute "Gedit ".a:commit.":".a:file
    endif
  endfunction
  "}}}
  " Git Checkout File Branch: {{{
  function s:GitEditBranchFile(branch)
    let [l:mode, l:commit] = split(substitute(a:branch, "\\(ctrl-.\\)\\?[ *\\n]*\\(remotes\\/\\)\\?\\([a-zA-Z0-9\\/:-]\\+\\).*", '\1 \3', ''), '', 1)
    call s:GitEditFile(l:mode, l:commit, '%')
  endfunction

  function s:FZFGitEditBranchFile()
    let l:fname = fnamemodify(expand("%"), ":~:.")
    let l:suffix = executable('delta') ? ' | delta --width $FZF_PREVIEW_COLUMNS' : ''
    let opts = {
          \ 'source': 'git branch -avv --color --sort=v:refname',
          \ 'sink': function('s:GitEditBranchFile'),
          \ 'options': "--delimiter='[* ]+' --nth=2 --print0 --tiebreak=index --expect=ctrl-v,ctrl-s --bind='ctrl-/:toggle-preview' --prompt 'ViewCurrentFile> ' --ansi --no-info --preview 'git diff HEAD..{2} " . l:fname . l:suffix ."'"}

    call s:FZFViewOpts(opts, 80, 70)
    call fzf#run(opts)
  endfunction

  command! -nargs=0 FZFGitEditBranchFile call s:FZFGitEditBranchFile()
  " }}}
  " Git Edit Commit File: {{{
  function s:GitEditCommitFile(commit)
    " TODO THIS FUNCTION IS CURRENTLY BROKEN
    if match(a:commit, 'ctrl-v') == 0 || match(a:commit, 'ctrl-s') == 0 || match(a:commit, 'enter') == 0
      let l:hash = substitute(a:commit[5:], "^[^0-9a-zA-Z]\\+ \\([0-9a-zA-Z]\\+\\).*", "\\1", "")
      let l:file = '%'
      let l:mode = split(a:commit, "", 1)[0]
    else
      let l:hash = substitute(a:commit, "^[^0-9a-zA-Z]\\+ \\([0-9a-zA-Z]\\+\\).*", "\\1", "")
      let opts = {
            \ 'source': 'git ls-tree --name-only -r ' . l:hash,
            \ 'sink': '"',
            \ 'options': "--expect=ctrl-v,ctrl-s --print0 --ansi --prompt 'ViewFile @ ".l:hash."> ' --inline-info --bind='ctrl-/:toggle-preview' --preview '~/.vim/plugged/fzf.vim/bin/preview.sh {}'"}

      call s:FZFViewOpts(opts, 80, 70)
      let l:file = fzf#run(fzf#wrap(opts))
      if len(l:file) == 0
        return
      endif
      if len(split(l:file[0], "", 1)) == 1
        let [l:mode, l:file] = ['', l:file[0]]
      else
        let [l:mode, l:file] = split(l:file[0], "", 1)
      endif
    endif
    call s:GitEditFile(l:mode, l:hash, l:file)
  endfunction

  function s:FZFGitEditCommitFile()
    let git_cmd = "git log --oneline --graph --pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s (%Cblue%an%Creset, %cr)' --date-order  --color=always"
    let opts = {
          \ 'source': git_cmd,
          \ 'sink': function('s:GitEditCommitFile'),
          \ 'options': "--prompt 'ViewFile> ' --ansi --layout=reverse-list --header ':: \e[1;33mEnter\e[m / \e[1;33mctrl-s\e[m / \e[1;33mctrl-v\e[m to open current file. \e[1;33mCtrl-Space\e[m to open file selection on that commit' --no-info --tiebreak=index --print0 --expect enter,ctrl-v,ctrl-s '--bind=ctrl-space:accept'"}
    call s:FZFViewOpts(opts, 80, 70)
    call fzf#run(opts)
  endfunction

  command! -nargs=0 FZFGitEditCommitFile call s:FZFGitEditCommitFile()
  " }}}

  " AsyncTasks Runner: {{{
  function s:RunTask(what)
    if len(a:what) < 2
      return
    endif
    let p1 = stridx(a:what[1], '|')
    if match(a:what[0], 'ctrl-l') == 0
      " type it
      let command = substitute(a:what[1][p1+2:], '^\s*\(.\{-}\)\s*$', '\1', '')
      if !exists('g:VimuxRunnerIndex') || match(VimuxTmux("list-panes -a -F '#{pane_id}'"), g:VimuxRunnerIndex)
        call VimuxOpenRunner()
      endif
      call VimuxSendText(trim(command) . ' ')
      call VimuxTmux('select-pane -t '.g:VimuxRunnerIndex)
    elseif match(a:what[0], 'ctrl-e') == 0
      exec "AsyncTaskEdit"
    else
      " run task
      if p1 >= 0
        let name = substitute(a:what[1][2:p1-1], '^\s*\(.\{-}\)\s*$', '\1', '')
        if name != ''
          exec "AsyncTask ". name
        endif
      endif
    endif
  endfunction

  function s:AsyncTaskFzf()
    let rows = asynctasks#source(999)
    let source = []
    for row in rows
      let type = substitute(substitute(row[1], '<local>', 'L', ''), '<global>', 'G', '')
      let source += ["\e[1;30m". trim(type) . "\e[m " . substitute(row[0], '[^#]\+#', "\e[1;34m&\e[m", '') . " \e[1;30m|  " . row[2] . "\e[m"]
    endfor
    let opts = {
          \ 'source': source,
          \ 'sink*': function('s:RunTask'),
          \ 'options': "+m --delimiter='[| ]+' --nth=2 --ansi --expect=ctrl-l,ctrl-e --prompt 'Run Task > ' --no-info  --header ':: \e[1;33menter\e[m Run command. \e[1;33mctrl-l\e[m Type command. \e[1;33mctrl-e\e[m Edit tasks file'"}

    call s:FZFViewOpts(opts, 50, 40)
    call fzf#run(opts)
  endfunction

  command! -nargs=0 AsyncTaskFzf call s:AsyncTaskFzf()
  " }}}

  " Vimux Pick Runner Pane: {{{
  function s:VimuxSetPane(line)
    let l:pane_path = substitute(a:line, '[* ]\+\([^:]\+\):\(\d\+\.\d\+\) .*','\1:\2', '')
    let g:VimuxRunnerIndex = substitute(VimuxTmux('display -t '.l:pane_path.' -p "#{pane_id}"'), '\n$', '', '')
  endfunction

  function s:VimuxPickPaneFzf()
    let opts = {
          \ 'source': 'tmux list-panes -a -F "\033[1;33m#{?pane_active,*, }\033[m|\033[1;30m#S:\033[m#I.#P|#{pane_current_command}|\033[1;30m#{?#{==:#W,#{pane_current_command}},,(#W)}\033[m|#{?window_linked,\033[1;36m[linked]\033[m,}"|column -ts"|" -o" "|while read -r l;do echo "$l";done',
          \ 'sink': function('s:VimuxSetPane'),
          \ 'options': "--prompt 'Vimux Pane> ' --delimiter='[* ]+' --nth=2.. --ansi --no-info --preview='tmux capture-pane -ep -t {2}|cat -s|tail -n $(tput lines)' --preview-window=up,70%"}

    call s:FZFViewOpts(opts, 60, 70)
    call fzf#run(opts)
  endfunction

  command! -nargs=0 FZFVimuxPickPane call s:VimuxPickPaneFzf()
  " }}}

  " Dap Api Command: {{{
  function s:DapCommandSink(cmd)
    execute 'lua ' . printf("require('dap')['%s']()", a:cmd)
  endfunction

  function s:DapCommandFZF()
    let commands = luaeval("vim.tbl_filter(function(k) return type(require('dap')[k]) == 'function' end, vim.tbl_keys(require('dap')))")
    call sort(commands)

    let opts = {
          \ 'source': commands,
          \ 'sink': function('s:DapCommandSink'),
          \ 'options': "--prompt 'DAP Command> '"}

    call s:FZFViewOpts(opts, 50, 60)
    call fzf#run(opts)
  endfunction

  command! -nargs=0 FZFDapCommand call s:DapCommandFZF()
  " }}}
  " Dap Api Breakpoints: {{{
  function s:DapBreakpointsSink(position)
    echo a:position
    " execute 'lua ' . printf("require('dap')['%s']()", a:cmd)
  endfunction

  function s:DapBreakpointsFZF()
    let breakpoints = luaeval(
          \"vim.tbl_map("
          \." function(bp) return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bp.bufnr), ':~:.') .. ':' .. (bp.lnum or '') .. ': ' .. (bp.text or '') .. (bp.condition and ' ' .. bp.condition or '') end,"
          \."(require('dap.breakpoints').to_qf_list(require('dap.breakpoints').get()) or {}) or {})")

    if empty(breakpoints)
      echohl ErrorMsg
      echomsg "No breakpoints set."
      echohl None
      return
    endif

    let opts = {
          \ 'source': breakpoints,
          \ 'options': ['--reverse', '--preview-window=up', '--prompt=DAP Breakpoints> ']
          \ }

    call s:FZFViewOpts(opts, 60, 60)
    call fzf#run(fzf#vim#with_preview(opts))
  endfunction

  command! -nargs=0 FZFDapBreakpoints call s:DapBreakpointsFZF()
  " }}}
endif
