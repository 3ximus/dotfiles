if &rtp =~ 'fzf.vim' && glob("~/.vim/plugged/fzf.vim/plugin/fzf.vim")!=#""

  " Functions: {{{
  " ------------------------------------
  "Gedit file with normally or with splits
  function GitEditFile(mode, commit, file)
    if match(a:mode, '&&&&') == 0
      execute "Gsplit ".a:commit.":".a:file
    elseif match(a:mode, '>>>>') == 0
      execute "Gvsplit ".a:commit.":".a:file
    else
      execute "Gedit ".a:commit.":".a:file
    endif
  endfunction

  " Function to checkout a file from another branch with FZF
  function! GitEditBranchFile(branch)
    let [l:mode, l:commit] = split(substitute(a:branch, "^\\(\\([&>#]\\{4\\}\\) *\\)\\? *\\([a-zA-Z0-9\\-]\\+/\\)*\\([^ \\/]\\+\\).*", "\\2 \\4", ""), "", 1)
    call GitEditFile(l:mode, l:commit, '%')
  endfunction
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

  " }}}
  " Commands: {{{
  " ------------------------------------
  command! -bang FZFGitEditCommitFile call fzf#run({'source': 'git lol --all', 'sink': function('GitEditCommitFile'), 'options': "--prompt 'ViewFile> ' --ansi --layout=reverse-list --header ':: \e[1;33mEnter\e[m / \e[1;33mctrl-s\e[m / \e[1;33mctrl-v\e[m to open current file. \e[1;33mCtrl-Space\e[m to open file selection on that commit' --nth=1 --no-info '--bind=enter:execute@printf \"#### \"@+accept' '--bind=ctrl-v:execute@printf \">>>> \"@+accept' '--bind=ctrl-s:execute@printf \"&&&& \"@+accept' '--bind=ctrl-space:accept'", 'tmux': '-p80%,70%'})
  command! -bang FZFGitEditBranchFile
        \ call fzf#run({
        \ 'source': 'git branch -avv --color',
        \ 'sink': function('GitEditBranchFile'),
        \ 'options': "'--bind=ctrl-v:execute@printf \">>>> \"@+accept' '--bind=ctrl-s:execute@printf \"&&&& \"@+accept' --prompt 'ViewCurrentFile> ' --ansi --no-info",
        \ 'tmux': '-p60%,40%'})
  " }}}

  endif
