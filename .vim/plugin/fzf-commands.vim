if &rtp =~ 'fzf.vim' && glob("~/.vim/plugged/fzf.vim/plugin/fzf.vim")!=#""
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

    if exists('$TMUX')
      let opts['tmux'] = '-p80%,70%'
    else
      let opts['window'] = { 'width': 0.8, 'height': 0.7 , 'border': 'sharp' }
    endif

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
      if exists('$TMUX')
        let opts['tmux'] = '-p80%,70%'
      else
        let opts['window'] = { 'width': 0.8, 'height': 0.7 , 'border': 'sharp' }
      endif
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
    if exists('$TMUX')
      let opts['tmux'] = '-p80%,70%'
    else
      let opts['window'] = { 'width': 0.8, 'height': 0.7 , 'border': 'sharp' }
    endif
    call fzf#run(opts)
  endfunction

  command! -nargs=0 FZFGitEditCommitFile call s:FZFGitEditCommitFile()
  " }}}

  " AsyncTasks Runner: {{{
  function s:RunTask(what)
    let p1 = stridx(a:what, '|')
    if match(a:what, 'ctrl-l') == 0
      " type it
      let command = substitute(a:what[p1+2:], '^\s*\(.\{-}\)\s*$', '\1', '')
      call VimuxOpenRunner()
      call VimuxSendText(trim(command) . ' ')
      call VimuxTmux('select-'.VimuxOption('VimuxRunnerType').' -t '.g:VimuxRunnerIndex)
    elseif match(a:what, 'ctrl-e') == 0
      exec "AsyncTaskEdit"
    else
      " run task
      if p1 >= 0
        let name = substitute(a:what[2:p1-1], '^\s*\(.\{-}\)\s*$', '\1', '')
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
          \ 'sink': function('s:RunTask'),
          \ 'options': "+m --delimiter='[| ]+' --nth=2 --ansi --expect=ctrl-l,ctrl-e --print0 --prompt 'Run Task > ' --no-info  --header ':: \e[1;33menter\e[m Run command. \e[1;33mctrl-l\e[m Type command. \e[1;33mctrl-e\e[m Edit tasks file'"}

    if exists('$TMUX')
      let opts['tmux'] = '-p50%,40%'
    else
      let opts['window'] = { 'width': 0.5, 'height': 0.4 , 'border': 'sharp' }
    endif

    call fzf#run(opts)
  endfunction

  command! -nargs=0 AsyncTaskFzf call s:AsyncTaskFzf()
  " }}}
endif
