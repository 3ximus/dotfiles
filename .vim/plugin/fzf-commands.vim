if &rtp =~ 'fzf.vim' && glob("~/.vim/plugged/fzf.vim/plugin/fzf.vim")!=#""

  " Sink Function Git Edit: {{{
  function GitEditFile(mode, commit, file)
    if match(a:mode, '&&&&') == 0
      execute "Gsplit ".a:commit.":".a:file
    elseif match(a:mode, '>>>>') == 0
      execute "Gvsplit ".a:commit.":".a:file
    else
      execute "Gedit ".a:commit.":".a:file
    endif
  endfunction
  "}}}
  " Git Checkout File Branch: {{{
  function! GitEditBranchFile(branch)
    let [l:mode, l:commit] = split(substitute(a:branch, "^\\(\\([&>#]\\{4\\}\\) *\\)\\? *\\([a-zA-Z0-9\\-]\\+/\\)*\\([^ \\/]\\+\\).*", "\\2 \\4", ""), "", 1)
    call GitEditFile(l:mode, l:commit, '%')
  endfunction

  command! -bang FZFGitEditBranchFile
        \ call fzf#run({
        \ 'source': 'git branch -avv --color',
        \ 'sink': function('GitEditBranchFile'),
        \ 'options': "'--bind=ctrl-v:execute@printf \">>>> \"@+accept' '--bind=ctrl-s:execute@printf \"&&&& \"@+accept' --prompt 'ViewCurrentFile> ' --ansi --no-info",
        \ 'tmux': '-p60%,40%'})
  " }}}
  " Git Edit Commit File: {{{
  function! GitEditCommitFile(commit)
    if match(a:commit, '>>>>') == 0 || match(a:commit, '&&&&') == 0 || match(a:commit, '####') == 0
      let l:hash = substitute(a:commit[5:], "^[^0-9a-zA-Z]\\+ \\([0-9a-zA-Z]\\+\\).*", "\\1", "")
      let l:file = '%'
      let l:mode = split(a:commit, "", 1)[0]
    else
      let l:hash = substitute(a:commit, "^[^0-9a-zA-Z]\\+ \\([0-9a-zA-Z]\\+\\).*", "\\1", "")
      " TODO preview here is not correct since it doesnt view the file content
      " on the selected commit
      let l:file = fzf#run(fzf#wrap({'source': 'git ls-tree --name-only -r ' . l:hash, 'sink': '"',
            \ 'options': "'--bind=ctrl-v:execute@printf \">>>> \"@+accept' '--bind=ctrl-s:execute@printf \"&&&& \"@+accept' --ansi --prompt 'ViewFile @ ".l:hash."> ' --inline-info --preview '~/.vim/plugged/fzf.vim/bin/preview.sh {}'",
            \ 'tmux': '-p80%,70%'}))
      if len(l:file) == 0
        return
      endif
      if len(split(l:file[0], "", 1)) == 1
        let [l:mode, l:file] = ['', l:file[0]]
      else
        let [l:mode, l:file] = split(l:file[0], "", 1)
      endif
    endif
    call GitEditFile(l:mode, l:hash, l:file)
  endfunction
  command! -bang FZFGitEditCommitFile call fzf#run({'source': 'git lol --all', 'sink': function('GitEditCommitFile'), 'options': "--prompt 'ViewFile> ' --ansi --layout=reverse-list --header ':: \e[1;33mEnter\e[m / \e[1;33mctrl-s\e[m / \e[1;33mctrl-v\e[m to open current file. \e[1;33mCtrl-Space\e[m to open file selection on that commit' --nth=1 --no-info '--bind=enter:execute@printf \"#### \"@+accept' '--bind=ctrl-v:execute@printf \">>>> \"@+accept' '--bind=ctrl-s:execute@printf \"&&&& \"@+accept' '--bind=ctrl-space:accept'", 'tmux': '-p80%,70%'})
  " }}}
  " AsyncTasks Runner: {{{
  function! s:RunTask(what)
    let p1 = stridx(a:what, '|')
    if p1 >= 0
      let name = substitute(a:what[2:p1-1], '^\s*\(.\{-}\)\s*$', '\1', '')
      if name != ''
        exec "AsyncTask ". name
      endif
    endif
  endfunction

  function! s:AsyncTaskFzf()
    let rows = asynctasks#source(&columns * 48 / 100)
    let source = []
    for row in rows
      let type = substitute(substitute(row[1], '<local>', 'L', ''), '<global>', 'G', '')
      let source += ["\e[1;30m". trim(type) . "\e[m " . substitute(row[0], '[^#]\+#', "\e[1;34m&\e[m", '') . " \e[1;30m|  " . row[2] . "\e[m"]
    endfor
    let opts = { 
          \ 'source': source,
          \ 'sink': function('s:RunTask'),
          \ 'options': "+m --delimiter='[| ]+' --nth=2 --ansi --prompt 'Run Task > ' --no-info '--bind=ctrl-l:execute@printf \">>>> \"@+accept' --header ':: \e[1;33mEnter\e[m Run command. \e[1;33mCtrl-l\e[m Type command'",
          \ 'tmux': '-p50%,40%'}

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
