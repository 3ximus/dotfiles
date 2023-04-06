" vim: foldmethod=marker foldlevel=0

" GENERIC SETTINGS {{{
" =====================

"encoding
set encoding=utf-8

"backspace functionality
set backspace=indent,eol,start

"use X clipboard as default
"you might need to install 'vim-gui-common' to enable clipboard support
set clipboard=unnamedplus

"line numbers
set relativenumber
set number
"set foldcolumn=0

"syntax and indentation
if !exists("g:syntax_on")
    syntax enable
endif
set tabstop=2 "number of spaces in a tab
set shiftwidth=2 "number of spaces for indent
set softtabstop=2 noexpandtab
set autoindent
set smartindent
set smarttab
"set expandtab "tabs are spaces, aka cancer
"setlocal lcs=tab:>-,trail:-,eol:¬ list! " use list mode mapped to F2 when vim is opened

set updatetime=400

set modeline

"search settings
set incsearch
set hlsearch

"split and buffer settings
set splitright
set splitbelow
set hidden "dont close buffers unless ordered to

"scrolling
set scrolloff=4

"swapfiles
set noswapfile
set nowritebackup

set autoread

"display command key pressed
set showcmd

set cmdheight=1

"autocomplete vim commands
set wildmenu
set wildmode=longest:list,full
set wildignorecase

" enable mouse for resizing window splits
set mouse=n
set ttymouse=xterm2

" To diable bell sounds, specially on windows
set noerrorbells visualbell t_vb=

" number text object (integer and float)
" --------------------------------------
" in
function! VisualNumber()
  call search('\d\([^0-9\.]\|$\)', 'cW')
  normal v
  call search('\(^\|[^0-9\.]\d\)', 'becW')
endfunction
xnoremap in :<C-u>call VisualNumber()<CR>
onoremap in :<C-u>normal vin<CR>

" }}}

" VIM PLUG PLUGINS {{{
" ===================

call plug#begin()

" COLORSCHEME
Plug '3ximus/gruvbox'

" BASE
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdtree', {'on':['NERDTreeToggle', 'NERDTreeFind']}
Plug '3ximus/fzf' " use my fork to allow passing g:fzf_no_term
Plug 'junegunn/fzf.vim'
Plug 'sjl/gundo.vim'
Plug 'junegunn/vim-peekaboo'
Plug 'jeetsukumaran/vim-markology'

" TOOLS
Plug 'tpope/vim-surround'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-repeat'
Plug 'easymotion/vim-easymotion'
Plug 'unblevable/quick-scope'
Plug 'AndrewRadev/linediff.vim'

" GIT
Plug 'Xuyuanp/nerdtree-git-plugin', {'on':['NERDTreeToggle', 'NERDTreeFind']}
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

Plug 'godlygeek/tabular', { 'on': ['Tabularize'] }

" COMPLETION
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" TMUX CLIPBOARD SHARING
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'roxma/vim-tmux-clipboard'

if exists('$TMUX')
  Plug 'preservim/vimux'
endif

" EXTRA SYNTAX HIGHLIGHT
let g:polyglot_disabled = ["sensible"]
Plug 'sheerun/vim-polyglot'

" EXTRAS
Plug 'mattn/emmet-vim'
" argument text object
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }

Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'

" OTHER
Plug 'mhinz/vim-startify'
"absolute numbers when window looses focus
Plug 'jeffkreeftmeijer/vim-numbertoggle'
"auto show fold column
Plug 'benknoble/vim-auto-origami'
Plug 'machakann/vim-highlightedyank'
" Profiler
if v:version >= 800
  Plug 'dstein64/vim-startuptime'
endif
" Support multiple emmet for vue files
Plug 'leafOfTree/vim-vue-plugin'

Plug 'habamax/vim-godot'

" vim go
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

"NerdFont icons in NerdTree, startify and Ctrl-p
Plug 'ryanoasis/vim-devicons'

call plug#end()

" }}}

" COLORSCHEME {{{
" ================

set t_Co=256 "terminal color range
try "try to set the theme as gruvbox
  colorscheme gruvbox
  let g:gruvbox_termcolors = 16 "256 colors look really bad
  set background=dark
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme darkblue
endtry

" makes the background be this color so that when reversed for the airline
" mode foreground it stays FUCKING BLACK!!
hi Normal ctermbg=236
"trasparent background
autocmd VimEnter * highlight Normal ctermbg=none
" highlight NonText ctermbg=none
" highlight CursorLineNr ctermbg=none

" }}}

" FUNCTIONS {{{
" ==============

"fold function to auto fold entire document based on indent
function! Fold(depth)
  let &foldnestmax = a:depth
  setlocal foldmethod=indent
endfunction
command! -nargs=1 Fold :call Fold( '<args>' ) "command to use Fold function

"remove trailing whitespaces
function! StripTrailingWhitespace()
  if !&binary && &filetype != 'diff'
    normal m'
    %s/\s\+$//e
    normal `'
  endif
endfunction

function! ConvertToTabs(tabsize)
  let &tabstop = a:tabsize
  let l:spaces = repeat(' ', &tabstop)
  set noexpandtab
  " get one of these to work...
  " silent! execute "%s/\(^\s*\)\@<=". l:spaces. "/\t/g"
  " :%s/\(^\s*\)\@<=". l:spaces. "/\t/g
  :retab!
endfunction
command! -nargs=1 ConvertToTabs :call ConvertToTabs( '<args>' )

function! ConvertToSpaces(spacesize)
  let &tabstop = a:spacesize
  let &sw = a:spacesize "number of spaces when indenting
  set expandtab
  %retab!
endfunction
command! -nargs=1 ConvertToSpaces :call ConvertToSpaces( '<args>' )

function! TabSpaceToogle()
  if &expandtab
    :call ConvertToTabs(&ts)
  else
    :call ConvertToSpaces(&sw)
  endif
endfunction

function! ClearRegisters()
  let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
  for r in regs
    call setreg(r, [])
  endfor
endfunction
command! -nargs=0 ClearRegisters :call ClearRegisters()

" FORMAT FUNCTIONS ===

function! Prettier()
  let saved_view = winsaveview()
  let modified = &modified
  silent %!prettier --no-color --stdin-filepath %
  cclose
  if v:shell_error > 0
    let l:errors = []
    for l:line in getline(1,'$')
      let l:match = matchlist(l:line, '^.*: \(.*\) (\(\d\{1,}\):\(\d\{1,}\)*)')
      if !empty(l:match)
        call add(l:errors, { 'bufnr': bufnr('%'), 'lnum': l:match[2], 'col': l:match[3] }) 'text': l:match[1],
      endif
    endfor

    silent undo
    call setqflist(l:errors, 'r')
    cwindow
  else
    if ! modified
      w
    endif
  endif
  call winrestview(saved_view)
  syntax sync fromstart
endfunction
noremap g= :call Prettier()<CR>

function! GoFmt()
  let saved_view = winsaveview()
  silent %!gofmt
  if v:shell_error > 0
    cexpr getline(1, '$')->map({ _, line -> line->substitute('<standard input>', expand('%'), '') })
    let l:errors = []
    for l:line in getline(1,'$')
      let l:match = matchlist(l:line, '^\([^:]\+\):\(\d\{1,}\):\(\d\{1,}\): \(.*\)')
      if !empty(l:match)
        call add(l:errors, { 'bufnr': bufnr('%'), 'text': l:match[4], 'lnum': l:match[2], 'col': l:match[3] , 'filename': l:match[1]})
      endif
    endfor

    silent undo
    call setqflist(l:errors, 'r')
    cwindow
  else
    cclose
  endif
  call winrestview(saved_view)
endfunction


" }}}

" KEYMAPS {{{
" ============

" map leader to space
nnoremap <space> <nop>
let mapleader=" "

" change buffers
nmap <C-P> :bp<CR>
nmap <C-N> :bn<CR>

nmap <C-W>n :tabnext<CR>
nmap <C-W>p :tabprevious<CR>
nmap <C-W>N :tabe %<CR>

" run macro saved to q
nnoremap <leader>q @q

" move line
nnoremap <C-j> :<C-U>m .+1<CR>
nnoremap <C-k> :<C-U>m .-2<CR>
inoremap <C-j> <Esc>:m .+1<CR>gi
inoremap <C-k> <Esc>:m .-2<CR>gi
vnoremap <C-j> :m '>+1<CR>gv
vnoremap <C-k> :m '<-2<CR>gv

" fold with fold nest max of 1
nmap zF :call Fold(v:count)<CR>:set foldmethod=manual<CR>
" nmap zM :set foldmethod=marker<CR>

" display line endings and tabs
nnoremap <F2> :<C-U>:execute 'setlocal lcs=tab:>-,trail:-,leadmultispace:\\|' . repeat('\ ', &sw -1) . ',eol:¬ list! list? '<CR>
" toogle paste mode (to prevent indenting when pasting)
set pastetoggle=<F3>

" Idenfigy syntax highlight value under the cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" start a search for visually selected text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

"use xclip, this is only needed if vim clipboard support isnt enabled
"you might need to install 'vim-gui-common' or 'vim-gtk' to enable clipboard support
vnoremap <leader>y :w !xclip -selection clipboard<CR><CR>
nnoremap <leader>yy :w !xclip -selection clipboard<CR><CR>

nmap <leader>x :bp<bar>bd #<CR>

" Clear search highlight and close preview window
nnoremap <silent> <backspace> :noh<CR>:pc<CR>:cclose<CR>:call CloseGstatus()<CR>:call CocCloseOutline()<CR>:call popup_clear(1)<CR>

" remove trailing whitespaces
nmap <leader>s :call StripTrailingWhitespace()<CR>
nnoremap <leader><Tab> :call TabSpaceToogle()<CR>

" save and load view of files
nmap <leader>vs :mkview<CR>
nmap <leader>vl :loadview<CR>

" jump forward and backward in quickfix results
noremap ]q :cnext<CR>
noremap [q :cprevious<CR>

" toogle wrap
nmap <leader>w :setlocal wrap!<CR>:setlocal wrap?<CR>


" recalculate syntxt highlight
nmap zz zz:syntax sync fromstart<CR>

" }}}

" HIGHLIGHT REDEFINITIONS {{{
" ============================

"GitGutter
highlight clear SignColumn
highlight link GitGutterAdd GruvboxGreen
highlight link GitGutterChange GruvboxYellow
highlight link GitGutterDelete GruvboxRed
highlight link GitGutterChangeDelete GruvboxYellow

" Markology
highlight link MarkologyHLl GruvboxYellowBold
highlight link MarkologyHLu GruvboxPurpleBold
highlight link MarkologyHLm GruvboxOrangeBold

" Coc
highlight link CocErrorSign GruvboxRedBold
highlight link CocWarningSign GruvboxYellowBold
highlight link CocInfoSign GruvboxPurpleBold
highlight link CocHintSign GruvboxBlueBold

if !has('gui_running')
  " Highlighted Yank
  highlight HighlightedyankRegion cterm=reverse gui=reverse

  highlight link logLevelInfo GruvboxBlueBold
  highlight Error cterm=bold ctermfg=234 ctermbg=9
  highlight ErrorMsg cterm=bold ctermfg=234 ctermbg=9
endif

" quick-scope
highlight link QuickScopePrimary GruvboxRedBold
highlight link QuickScopeSecondary GruvboxOrangeBold

" }}}

" PLUGIN CONFIGURATION {{{
" =========================

"startify
let g:startify_change_to_dir = 0
let g:startify_fortune_use_unicode = 1
" let g:ascii = [
"       \ '             ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ',
"       \ '              ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ',
"       \ '                    ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ',
"       \ '                     ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ',
"       \ '                    ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ',
"       \ '             ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ',
"       \ '            ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ',
"       \ '           ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ',
"       \ '           ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ',
"       \ '                ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ',
"       \ '                 ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ',
"       \]
" let g:startify_custom_header =
"       \ 'startify#center(g:ascii + startify#fortune#boxed())'
let g:startify_custom_header =
    \ 'startify#pad(startify#fortune#cowsay())'

function! s:gitModified()
    let files = systemlist('git ls-files -m 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
endfunction
" same as above, but show untracked files, honouring .gitignore
function! s:gitUntracked()
    let files = systemlist('git ls-files -o --exclude-standard 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
endfunction

let g:startify_lists = [
        \ { 'type': 'files',     'header': ['   MRU']            },
        \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
        \ { 'type': function('s:gitModified'),  'header': ['   Git modified']},
        \ { 'type': function('s:gitUntracked'), 'header': ['   Git untracked']},
        \ ]


"NERDTree
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''
let g:NERDTreeMinimalUI=1
let g:NERDTreeCreatePrefix='silent keepalt keepjumps'
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeMinimalMenu=1

"nerdtree-git
" let g:NERDTreeGitStatusConcealBrackets = 1 " default: 0
" let g:NERDTreeGitStatusShowClean = 1 " default: 0
" let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0
let g:NERDTreeGitStatusIndicatorMapCustom = {
      \ 'Modified'  :'∗',
      \ 'Staged'    :'→',
      \ 'Untracked' :'%',
      \ 'Renamed'   :'↻',
      \ 'Unmerged'  :'═',
      \ 'Deleted'   :'✘',
      \ 'Dirty'     :'∗',
      \ 'Ignored'   :'?',
      \ 'Clean'     :'✔',
      \ 'Unknown'   :'?',
      \ }

" devicons
" let g:WebDevIconsNerdTreeBeforeGlyphPadding = ''
let g:webdevicons_enable_airline_statusline = 0
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:DevIconsEnableDistro = 0

"Auto Origami (auto manage fold columns)
if exists('&belloff') && &rtp =~ 'vim-auto-origami' && glob("~/.vim/plugged/vim-auto-origami/plugin/auto_origami.vim")!=#""
  augroup auto_origami
    au!
    au CursorHold,BufWinEnter,WinEnter * AutoOrigamiFoldColumn
  augroup END
  let g:auto_origami_foldcolumn = 1
endif

" Gitgutter
let g:gitgutter_sign_added = '┃'
let g:gitgutter_sign_modified = '┃'
let g:gitgutter_sign_modified_removed = '┻'

" Gundo
if has('python3')
    let g:gundo_prefer_python3 = 1
endif

" Markology
let g:markology_include='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

" quick-scope
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" Vimux
let g:VimuxPromptString = "$ "
let g:VimuxExpandCommand = 1

"Python syntax highlight
let g:python_highlight_all = 1
let g:python_highlight_indent_errors = 1
let g:python_highlight_space_errors = 0
let g:python_highlight_operators = 0

" vim-vue-plugin
let g:vim_vue_plugin_config = {
  \'syntax': {
  \  'template': ['html'],
  \  'script': ['typescript', 'javascript'],
  \  'style': ['scss'],
  \},
\}

" vim-go (with vim-polyglot)
let g:go_highlight_function_parameters = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1
let g:go_highlight_variable_declarations = 1
let g:go_highlight_variable_assignments = 1

" vim-svelte-plugin (with vim-polyglot)
let g:vim_svelte_plugin_load_full_syntax = 1
let g:vim_svelte_plugin_use_typescript = 1
let g:vim_svelte_plugin_use_sass = 1
let g:vim_svelte_plugin_has_init_indent = 1

" }}}

" PLUGIN KEYMAPS {{{
" ===================

map <C-t> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>
nnoremap U :GundoToggle<CR>
let NERDTreeMapOpenSplit='s'
let NERDTreeMapOpenVSplit='v'

" Inline edit
nmap <leader>i :InlineEdit<CR>

omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
" <leader>hs is the default for staging
vmap <leader>ha <Plug>(GitGutterStageHunk)
nmap <leader>ha <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>hv <Plug>(GitGutterPreviewHunk)
nmap <leader>hd <Plug>(GitGutterDiffOrig)
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>hf :GitGutterFold<CR>

"nertree git
let g:NERDTreeGitStatusMapNextHunk=']h'
let g:NERDTreeGitStatusMapPrevHunk='[h'

"fugitive
function! CloseGstatus() abort
  for l:winnr in range(1, winnr('$'))
    if !empty(getwinvar(l:winnr, 'fugitive_status'))
      execute l:winnr.'close'
    endif
  endfor
endfunction
noremap <leader>gs :Git\|12wincmd_<CR>
noremap <leader>gd :Gvdiffsplit!<CR>
noremap <leader>gl :0Gclog<CR>:copen<CR>
noremap <leader>gL :G log --graph<CR>
vmap <leader>gl :Gclog<CR>:copen<CR>
noremap <leader>gB :Git blame<CR>
noremap <leader>gp :Git push<CR>

" create a popup with git info about the current line
nmap <silent><Leader>gm :call setbufvar(winbufnr(popup_atcursor(split(system("git log -n 1 -L " . line(".") . ",+1:" . expand("%:p")), "\n"), { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 })), "&filetype", "git")<CR>

if !exists(":Gdiffoff")
  command Gdiffoff diffoff | q | Gedit
endif
noremap <leader>gD :Gdiffoff<CR>

" Line diff
noremap <leader>D :LinediffReset<CR>
noremap <leader>d :Linediff<CR>

" Emmet mappings
nmap <leader>E :Emmet<space>
let g:user_emmet_leader_key='<C-y>'
let g:user_emmet_expandabbr_key='<C-e>'
let g:user_emmet_mode='inv'
imap <C-e> <plug>(emmet-expand-abbr)

"Vimux
noremap <leader>rc :VimuxPromptCommand<CR>
noremap <leader>rl :VimuxRunLastCommand<CR>
noremap <leader>rk :VimuxInterruptRunner<CR>
noremap <leader>rq :VimuxCloseRunner<CR>
noremap <leader>ro :VimuxOpenRunner<CR>
noremap <leader>ri :VimuxInspectRunner<CR>
function! VimuxSendSelectedText() range
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  let selectedText = join(lines, "\n")
  call VimuxSendText(selectedText)
endfunction
xnoremap <leader>rr :call VimuxSendSelectedText()<CR>

" Tabularize
if isdirectory(expand("~/.vim/plugged/tabular"))
  nmap <leader>a& :Tabularize /&<CR>
  vmap <leader>a& :Tabularize /&<CR>
  nmap <leader>a= :Tabularize /^[^=]*\zs=<CR>
  vmap <leader>a= :Tabularize /^[^=]*\zs=<CR>
  nmap <leader>a=> :Tabularize /=><CR>
  vmap <leader>a=> :Tabularize /=><CR>
  nmap <leader>a: :Tabularize /:<CR>
  vmap <leader>a: :Tabularize /:<CR>
  nmap <leader>a; :Tabularize /;<CR>
  vmap <leader>a; :Tabularize /;<CR>
  nmap <leader>a:: :Tabularize /:\zs<CR>
  vmap <leader>a:: :Tabularize /:\zs<CR>
  nmap <leader>a, :Tabularize /,<CR>
  vmap <leader>a, :Tabularize /,<CR>
  nmap <leader>a,, :Tabularize /,\zs<CR>
  vmap <leader>a,, :Tabularize /,\zs<CR>
  nmap <leader>a<Bar> :Tabularize /<Bar><CR>
  vmap <leader>a<Bar> :Tabularize /<Bar><CR>
endif
" }}}

" AIRLINE CONFIGURATION {{{
" =========================

if &rtp =~ 'vim-airline' && glob("~/.vim/plugged/vim-airline/plugin/airline.vim")!=#""
  let g:airline_powerline_fonts=1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#fnamemod = ':p:.' "show only file names on buffer names
  let g:airline#extensions#tabline#buffer_nr_show = 0
  let g:airline#extensions#tabline#fnamecollapse = 1
  let g:airline#extensions#tabline#show_close_button = 0
  let g:airline#extensions#tabline#show_tabs = 0
  let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  let g:airline#extensions#whitespace#mixed_indent_algo = 1
  let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]' "hide encoding if its utf8
  let g:airline#extensions#hunks#enabled=1
  let g:airline#extensions#hunks#non_zero_only = 1
  let g:airline#extensions#term#enabled = 0

  " coc airline configuration
  let g:airline#extensions#coc#error_symbol = ' '
  let g:airline#extensions#coc#warning_symbol = ' '
  let g:airline#extensions#coc#show_coc_status = 0 " handled in custom section
  let g:airline#extensions#coc#stl_format_err = '%C' " can use %L for line number
  let g:airline#extensions#coc#stl_format_warn = '%C'
  let g:airline#extensions#searchcount#enabled = 0 " handled in custom section

  let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'd', 'w', 'y', 'z', 'warning', 'error']]

  call airline#parts#define('coc_status_symbol', { 'raw': '%#__restore__#%{get(g:, "coc_status", "") != "" ? (get(g:, "coc_enabled", "") == 1 ? "" : "" ) : ""}'})
  call airline#parts#define('coc_status', { 'raw': ' %{airline#util#shorten(trim(get(g:, "coc_status", "")), 100, 6)}'})
  call airline#parts#define('max_line', { 'raw': '%L', 'accent': 'bold'})
  call airline#parts#define('new_search_count', { 'raw': '%{v:hlsearch ? trim(airline#extensions#searchcount#status()) : ""}', 'accent': 'bold'})
  call airline#parts#define('filename_path',  {'raw': '%<%{expand("%:p:h")}/'})
  call airline#parts#define('filename',  {'raw': '%<%t%m ', 'accent':'bold'})

  let g:airline_section_c = airline#section#create(['filename_path', 'filename', 'readonly'])
  let g:airline_section_d = airline#section#create(['coc_status_symbol'])
  " let g:airline_section_d = airline#section#create(['coc_status_symbol', 'coc_status'])
  let g:airline_section_x = airline#section#create(['%{airline#util#wrap(airline#parts#filetype() . " " . WebDevIconsGetFileTypeSymbol(),140)}'])
  let g:airline_section_w = airline#section#create(['%{get(b:,"coc_current_function","")}'])
  let g:airline_section_y = airline#section#create(['%{airline#util#wrap(airline#parts#ffenc(),0)}', 'new_search_count'])
  let g:airline_section_z = airline#section#create(['%p%% %l/', 'max_line', ':%c'])

  " set color on custom sections
  autocmd User AirlineAfterTheme let g:airline#themes#gruvbox#palette.normal.airline_w = ['#282828', '#8ec07c', 0, 14]
  autocmd User AirlineAfterTheme let g:airline#themes#gruvbox#palette.normal.airline_d = ['#ebdbb2', '#458588', 15, 4]

  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif

  let g:airline_mode_map = {
    \ '__'     : '-',
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'ic'     : 'I',
    \ 'ix'     : 'I',
    \ 'n'      : 'N',
    \ 'multi'  : 'M',
    \ 'ni'     : 'N',
    \ 'no'     : 'N',
    \ 'R'      : 'R',
    \ 'Rv'     : 'R',
    \ 's'      : 'S',
    \ 'S'      : 'S',
    \ ''     : 'S',
    \ 't'      : 'T',
    \ 'v'      : 'V',
    \ 'V'      : 'VL',
    \ ''     : 'VB',
    \ }

  "this will only worke with patched fonts from NERD FONTS
  let g:airline_left_sep = "\uE0B8"
  let g:airline_right_sep = "\uE0BA"
  let g:airline_left_alt_sep = "\uE0B9"
  let g:airline_right_alt_sep =  "\uE0BB"

  "no symbols
  let g:airline_left_sep = ""
  let g:airline_right_sep = ""
  let g:airline_left_alt_sep = ""
  let g:airline_right_alt_sep =  ""

  let g:airline_symbols.notexists = '%'
  let g:airline_symbols.dirty = '*'
endif

" }}}

" FZF CONFIGURATION {{{
" =====================

if &rtp =~ 'fzf.vim' && glob("~/.vim/plugged/fzf.vim/plugin/fzf.vim")!=#""
  let g:fzf_command_prefix = 'FZF'

  if exists('$TMUX')
    let g:fzf_layout = { 'tmux': '-p90%,60%' }
  else
    " let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 , 'border': 'sharp'} } " Causes airline gruvbox bug
    let g:fzf_no_term = 1
    let g:fzf_layout = { 'down': '30%' }
  endif

  " autocmd! FileType fzf
  " autocmd  FileType fzf set laststatus=0 noshowmode noruler
  "     \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

  let g:fzf_history_dir = '~/.local/share/fzf-history'

  " function to make quick fiz with selected results
  function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
  endfunction

  " Function to checkout a branch with FZF
  function! GitCheckoutBranch(branch)
    " branch can look like this: "/remotes/origin/master [hash] info" or this: "master [hash] info"
    let l:name = split(split(trim(a:branch), "", 1)[0], "/", 1)[-1]
    execute "Git checkout ".l:name
  endfunction
  command! -bang FZFGbranch call fzf#run({'source': 'git branch -avv --color', 'sink': function('GitCheckoutBranch'), 'options': '--ansi --nth=1', 'tmux': '-p60%,40%'})

  " Function to checkout a file from another branch with FZF
  function! GitEditBranchFile(branch)
    if match(a:branch, '&&&& ') == 0
      let l:name = split(split(trim(a:branch), "", 1)[1], "/", 1)[-1]
      execute "Gsplit ".l:name.":%"
    elseif match(a:branch, '>>>> ') == 0
      let l:name = split(split(trim(a:branch), "", 1)[1], "/", 1)[-1]
      execute "Gvsplit ".l:name.":%"
    else
      let l:name = split(split(trim(a:branch), "", 1)[0], "/", 1)[-1]
      execute "Gedit ".l:name.":%"
    endif
  endfunction
  command! -bang FZFGeditFile call fzf#run({'source': 'git branch -avv --color', 'sink': function('GitEditBranchFile'), 'options': "'--bind=ctrl-v:execute@printf \">>>> \"@+accept' '--bind=ctrl-s:execute@printf \"&&&& \"@+accept' --ansi --nth=1", 'tmux': '-p60%,40%'})

  let g:fzf_action = {
        \ 'ctrl-q': function('s:build_quickfix_list'),
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit' }

  command! -bang -nargs=* FZFRg
        \ call fzf#vim#grep('rg --no-heading --line-number --color=always --smart-case '.shellescape(<q-args>),
        \ 1,
        \ fzf#vim#with_preview({'options': '--delimiter : --nth 2..'}),
        \ <bang>0)

  command! -bang -nargs=* FZFRgWithFilenames
        \ call fzf#vim#grep('rg --no-heading --line-number --color=always --smart-case '.shellescape(<q-args>),
        \ 1,
        \ fzf#vim#with_preview(),
        \ <bang>0)

  nmap <expr> <leader>p fugitive#Head() != '' ? ':FZFGFiles<CR>' : ':FZFFiles<CR>'
  nmap <leader>P :FZFFiles<CR>
  nmap <leader>b :FZFBuffers<CR>
  nmap <leader>l :FZFLines<CR>
  nmap <leader>f :FZFRg<CR>
  nmap <leader>F :FZFRgWithFilenames<CR>
  nmap <leader>/ :FZFHistory/<CR>
  nmap <leader>: :FZFHistory:<CR>
  nmap <leader>m :FZFMaps:<CR>

  noremap <leader>gv :FZFGeditFile<CR>
  noremap <leader>gb :FZFGbranch<CR>
  noremap <leader>gc :FZFCommits<CR>
  vmap <leader>gc :FZFBCommits<CR>
endif
" }}}

" COC CONFIGURATION {{{
" ======================

if !executable('node')
  let g:coc_start_at_startup = 0
endif

if &rtp =~ 'coc.nvim' && glob("~/.vim/plugged/coc.nvim/plugin/coc.vim")!=#""

  let g:coc_disable_startup_warning = 1

  " Coc Extensions
  let g:coc_global_extensions = [
        \'coc-json',
        \'coc-sh',
        \]

  " map ctrl-space to get coc completion
  inoremap <silent><expr> <c-@> coc#refresh()

  " Use `[d` and `]d` to navigate diagnostics
  " Use `:cocDiagnostics` to get all diagnostics of current buffer in location list.
  nmap <silent> [d <Plug>(coc-diagnostic-prev)
  nmap <silent> ]d <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gr <Plug>(coc-references)

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>
  nnoremap <silent> <leader>K :execute '!' . &keywordprg . " " . expand('<cword>')<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
      call CocActionAsync('definitionHover')
    else
      execute '!' . &keywordprg . " " . expand('<cword>')
    endif
  endfunction

  " Map function and class text objects
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)
  xmap ic <Plug>(coc-classobj-i)
  omap ic <Plug>(coc-classobj-i)
  xmap ac <Plug>(coc-classobj-a)
  omap ac <Plug>(coc-classobj-a)

  " Allow auto import when using C-n and C-p for navigating suggestions
  inoremap <silent><expr> <C-n> coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"
  inoremap <silent><expr> <C-p> coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"
  inoremap <silent><expr> <down> coc#pum#visible() ? coc#pum#next(0) : "\<down>"
  inoremap <silent><expr> <up> coc#pum#visible() ? coc#pum#prev(0) : "\<up>"
  inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"
  inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<Tab>"

  function! CocToggle()
    if g:coc_enabled
      CocDisable
    else
      CocEnable
    endif
  endfunction
  command! CocToggle :call CocToggle()

  " it actually also closes CocTree with Outgoing and Incoming calls to be more convenient
  function! CocCloseOutline()
    let winid = coc#window#find('cocViewId', 'OUTLINE')
    if winid != -1
      call CocAction('hideOutline')
    endif
    let winid = coc#window#find('cocViewId', 'calls')
    if winid != -1
      call coc#window#close(winid)
    endif
  endfunction

  function! CocOutlineToggle()
    let winid = coc#window#find('cocViewId', 'OUTLINE')
    if winid == -1
      call CocAction('showOutline')
    else
      call CocAction('hideOutline')
    endif
  endfunction

  command! -nargs=0 Format :call CocActionAsync('format')
  command! -nargs=0 OrganizeImports   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

  " Mappings for Coc
  nmap <leader>ca  <Plug>(coc-codeaction-cursor)
  nmap <leader>cA  <Plug>(coc-codeaction)
  nnoremap <silent><nowait> <leader>cd  :<C-u>CocList diagnostics<CR>
  nnoremap <silent><nowait> <leader>ce  :<C-u>CocList extensions<CR>
  nnoremap <silent><nowait> <leader>cc  :<C-u>CocList commands<CR>
  nnoremap <silent><nowait> <leader>cs  :<C-u>CocList services<CR>
  nnoremap <silent><nowait> <leader>co  :<C-u>call CocOutlineToggle()<CR>
  nnoremap <silent><nowait> <leader>ct  :<C-u>CocToggle<CR>
  nnoremap <silent><nowait> <leader>cf  :<C-u>call CocAction('showOutgoingCalls')<CR>
  nnoremap <silent><nowait> <leader>cr  :<C-u>call CocAction('showIncomingCalls')<CR>
endif

" }}}

" GUI SPECIFIC {{{
" =================

if has("gui_running")
  colorscheme gruvbox
  let g:gruvbox_contrast_dark = 'medium'
  let g:gruvbox_contrast_light = 'soft'
  set background=dark

  "set guifont=Roboto\ Mono\ for\ Powerline\ Regular\ 9
  "set guifont=Source\ Code\ Pro\ for\ Powerline\ Medium\ 9
  "set guifont=Fira\ Mono\ for\ Powerline\ 9
  set guifont=TerminessTTF\ Nerd\ Font\ Mono\ 13

  set linespace=0

  set guicursor+=a:blinkon0

  "hide toolbar, scrollbar and menubar
  set guioptions-=L
  set guioptions-=l
  set guioptions-=R
  set guioptions-=r
  set guioptions-=m
  set guioptions-=T
  set guioptions-=e

endif

" }}}

" FILE SPECIFIC {{{
" ==================

autocmd FileType vim setlocal foldmethod=marker foldlevel=0

autocmd FileType python setlocal tabstop=2 shiftwidth=2 softtabstop=2 noexpandtab autoindent "because someone has too much screen space in their eyesight
autocmd FileType python setlocal indentkeys-=<:> " colon will auto indent line in insert mode, remove that behavior
autocmd FileType python setlocal indentkeys-=:

" use dart#dmt or :DartFmt to format the dart file
autocmd FileType dart setlocal formatexpr=dart#fmt()

" must be used from the first line
autocmd FileType json setlocal formatprg=python3\ -m\ json.tool

autocmd FileType go map g= :call GoFmt()<CR>

" add @ completion
autocmd FileType scss setl iskeyword+=@-@

" disable folding on output of dadbod-ui
autocmd FileType dbout setlocal nofoldenable

" }}}

" RUN COMMANDS ON EVENTS {{{
" ===========================

" assumes set noignorecase
if exists('##CmdLineEnter')
  augroup dynamic_smartcase
    autocmd!
    autocmd CmdLineEnter : set ignorecase
    autocmd CmdLineLeave : set noignorecase
  augroup END
endif

" fix artifacts on screen from tmux-focus-events
autocmd FocusGained * silent redraw!
" autocmd FocusLost * silent redraw!

" }}}
