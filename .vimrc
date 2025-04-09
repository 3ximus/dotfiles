" vim: foldmethod=marker foldlevel=0

" GENERIC {{{
" =====================

"encoding
set encoding=utf-8

"backspace functionality
set backspace=indent,eol,start

"you might need to install 'vim-gui-common' to enable clipboard support
set clipboard=unnamedplus

set relativenumber
set number
set nuw=3
set foldcolumn=auto:1

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
set nowrap
"set expandtab "tabs are spaces, aka cancer
"setlocal lcs=tab:>-,trail:-,eol:¬ list! " use list mode mapped to F2 when vim is opened

set updatetime=400

set modeline
" Load bash aliases in here
let $BASH_ENV="~/.bash/aliases.sh"

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
set noshowmode

"autocomplete vim commands
set wildmenu
set wildmode=longest:list,full
set wildignorecase

" enable mouse for resizing window splits
set mouse=n
set guicursor=a:blinkon0
if !has('nvim')
  set ttymouse=xterm2
endif

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

" when running command W run w instead (preventing typos)
cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))

" }}}

" PLUGINS {{{
" ===================

call plug#begin('~/.vim/plugged')

if has('nvim')
  Plug '3ximus/gruvbox.nvim'
  Plug 'stevearc/oil.nvim'
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'luukvbaal/statuscol.nvim'
  Plug 'ibhagwan/fzf-lua'

  " DAP
  Plug 'mfussenegger/nvim-dap'
  Plug 'nvim-neotest/nvim-nio'
  Plug 'rcarriga/nvim-dap-ui'
  " nodejs debug
  " Plug 'mxsdev/nvim-dap-vscode-js' -- I do this manually now
  Plug 'microsoft/vscode-js-debug', { 'do': 'npm ci --legacy-peer-deps && npx gulp dapDebugServer' }
  " python debug
  Plug 'mfussenegger/nvim-dap-python'
else
  Plug '3ximus/gruvbox'
  Plug '3ximus/vim-airline' " my fork switches position of the tabs and splits on tabline

  " fzf
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'stsewd/fzf-checkout.vim', { 'on': ['FZFGBranches', 'FZFGTags'] }
  Plug 'antoinemadec/coc-fzf'
endif

" BASE
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
Plug 'sjl/gundo.vim', { 'on': 'GundoToggle' }
Plug 'junegunn/vim-peekaboo'
Plug 'jeetsukumaran/vim-markology'
Plug 'wellle/context.vim', { 'on': 'ContextToggle' }
Plug 'markonm/traces.vim' " highlight patterns and ranges in command
Plug 'machakann/vim-highlightedyank'

Plug 'skywind3000/asyncrun.vim'
Plug 'orrors/asynctasks.vim'

" TOOLS
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tomtom/tcomment_vim'
Plug 'justinmk/vim-sneak'
" Plug 'ggandor/leap.nvim'
Plug 'AndrewRadev/linediff.vim'
Plug 'fidian/hexmode'
Plug 'lambdalisue/vim-suda', { 'on': ['SudaRead', 'SudaWrite'] }

" GIT
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'godlygeek/tabular', { 'on': ['Tabularize'] }

" COMPLETION
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

if exists('$TMUX')
  " Plug 'preservim/vimux'
  Plug '3ximus/vimux'
endif

" LANGUAGE STUFF
let g:polyglot_disabled = ["sensible"]
" Plug 'sheerun/vim-polyglot' " hasn't been updated in a while and we need a fix
Plug '00dani/vim-polyglot', { 'branch' : 'feature/fix-build' }
Plug 'mattn/emmet-vim'

" DATABASE
Plug 'tpope/vim-dadbod', { 'on': 'DBUI' }
Plug 'kristijanhusak/vim-dadbod-ui', { 'on': 'DBUI' }
Plug 'jidn/vim-dbml', { 'for': 'dbml' }

" OTHER
Plug 'mhinz/vim-startify'
Plug 'SarveshMD/vim-devicons'
Plug 'vim-test/vim-test', { 'on': ['TestNearest', 'TestFile'] }

if v:version >= 800
  Plug 'dstein64/vim-startuptime' " Profiler
endif

call plug#end()

" }}}

" COLORSCHEME {{{
" ================

set t_Co=256 "terminal color range
try "try to set the theme as gruvbox
  let g:gruvbox_termcolors = 16 "256 colors look really bad
  let g:gruvbox_improved_warnings = 1
  set background=dark
  colorscheme gruvbox
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme darkblue
endtry

" This is now handled on my fork of gruvbox
" makes the background be this color so that when reversed for the airline
" mode foreground it stays FUCKING BLACK!!
" hi Normal ctermbg=236
"trasparent background
" autocmd VimEnter * highlight Normal ctermbg=none

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

" }}}

" KEYMAPS {{{
" ============

" map leader to space
nnoremap <space> <nop>
let mapleader=" "

" disable F1 help key
map <F1> <Esc>
imap <F1> <Esc>

" change buffers
nmap <C-P> :bp<CR>
nmap <C-N> :bn<CR>

" jumplists remaps
nmap <C-H> <C-O>
nmap <C-L> <C-I>

nmap <C-W>n :tabnext<CR>
nmap <C-W>p :tabprevious<CR>
nmap <C-W>N :tabe %<CR>

nnoremap <A-h> <C-W>h
nnoremap <A-j> <C-W>j
nnoremap <A-k> <C-W>k
nnoremap <A-l> <C-W>l

" run macro saved to q
nnoremap <leader>q @q

" move line
" nnoremap <C-j> :<C-U>m .+1<CR>
" nnoremap <C-k> :<C-U>m .-2<CR>
" inoremap <C-j> <Esc>:m .+1<CR>gi
" inoremap <C-k> <Esc>:m .-2<CR>gi
" vnoremap <C-j> :m '>+1<CR>gv
" vnoremap <C-k> :m '<-2<CR>gv

map Y y$

" fold with fold nest max of 1
nmap zF :call Fold(v:count)<CR>:set foldmethod=manual<CR>
" nmap zM :set foldmethod=marker<CR>

" display line endings and tabs
nnoremap <silent><F2> :<C-U>:execute 'setlocal lcs=tab:>-,trail:-,leadmultispace:\\|' . repeat('\ ', &sw -1) . ',eol:¬ list! list? '<CR>
" toogle paste mode (to prevent indenting when pasting)
set pastetoggle=<F4>

" Idenfigy syntax highlight value under the cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" start a search for visually selected text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

nmap <leader>x :bp<bar>bd#<CR>
" close all other buffers
nmap <leader>X :%bd<bar>e#<bar>bd#<CR>

" Clear search highlight and close preview window
if has('nvim')
  nnoremap <silent> <backspace> :noh<CR>:pc<CR>:cclose<CR>:helpclose<CR>:call CloseGstatus()<CR>:call CocCloseOutline()<CR>
else
  nnoremap <silent> <backspace> :noh<CR>:pc<CR>:cclose<CR>:helpclose<CR>:call CloseGstatus()<CR>:call CocCloseOutline()<CR>:call popup_clear(1)<CR>
endif

" remove trailing whitespaces
nmap <leader>s :call StripTrailingWhitespace()<CR>
nnoremap <leader><Tab> :call TabSpaceToogle()<CR>

" save and load view of files
nmap <leader>vs :mkview<CR>
nmap <leader>vl :loadview<CR>

" jump forward and backward in quickfix results
noremap ]q :cnext<CR>
noremap [q :cprevious<CR>

noremap ]c />>>>>>>\\|<<<<<<<<CR>
noremap [c ?>>>>>>>\\|<<<<<<<<CR>

" toogle wrap
nmap <leader>w :setlocal wrap!<CR>:setlocal wrap?<CR>

" recalculate syntax highlight
nmap zz zz:syntax sync fromstart<CR>

" 3 way diff get bindings
nmap gh :diffget //3<CR>
nmap gl :diffget //2<CR>

vnoremap <leader>u] :B !python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.stdin.read()));'<cr>
vnoremap <leader>u[ :B !python3 -c 'import sys,urllib.parse;print(urllib.parse.unquote(sys.stdin.read()));';<cr>

" }}}

" HIGHLIGHT {{{
" ============================

if !(has('nvim') && luaeval('vim.version()').major == 0 && luaeval('vim.version()').major == 0 && luaeval('vim.version()').minor >= 10)
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
endif

if !has('gui_running')
  " Highlighted Yank
  highlight HighlightedyankRegion cterm=reverse gui=reverse

  highlight link logLevelInfo GruvboxBlueBold
  highlight Error cterm=bold ctermfg=234 ctermbg=9
  highlight ErrorMsg cterm=bold ctermfg=234 ctermbg=9
endif

" }}}

" PLUGIN CONFIGURATION {{{
" =========================

"startify
let g:startify_change_to_dir = 0
let g:startify_fortune_use_unicode = 1
" let g:startify_custom_header =
"     \ 'startify#pad(startify#fortune#cowsay())'
" let g:ascii = [
      " \ '             ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ',
      " \ '              ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ',
      " \ '                    ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ',
      " \ '                     ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ',
      " \ '                    ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ',
      " \ '             ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ',
      " \ '            ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ',
      " \ '           ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ',
      " \ '           ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ',
      " \ '                ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ',
      " \ '                 ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ',
      " \]
" let g:startify_custom_header =
"       \ 'startify#pad(g:ascii + startify#fortune#boxed())'
let g:startify_custom_header =
      \ 'startify#pad(startify#fortune#boxed())'

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
        \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
        \ { 'type': function('s:gitModified'),  'header': ['   Git modified']},
        \ { 'type': function('s:gitUntracked'), 'header': ['   Git untracked']},
        \ { 'type': 'files',     'header': ['   MRU']            },
        \ ]

"NERDTree
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''
let g:NERDTreeMinimalUI=1
let g:NERDTreeCreatePrefix='silent keepalt keepjumps'
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeMinimalMenu=1
let g:NERDTreeHijackNetrw=1

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
let g:webdevicons_enable_airline_tabline = 0
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:DevIconsEnableDistro = 0

" context.vim
let g:context_add_mappings = 0
let g:context_enabled = 0

"auto-origami (auto manage fold columns)
if exists('&belloff') && &rtp =~ 'vim-auto-origami' && glob("~/.vim/plugged/vim-auto-origami/plugin/auto_origami.vim")!=#""
  augroup auto_origami
    au!
    au CursorHold,BufWinEnter,WinEnter * AutoOrigamiFoldColumn
  augroup END
  let g:auto_origami_foldcolumn = 1
endif

" gitgutter
let g:gitgutter_sign_added = '┃'
let g:gitgutter_sign_modified = '┃'
let g:gitgutter_sign_modified_removed = '┻'
let g:gitgutter_preview_win_floating = 1
let g:gitgutter_floating_window_options = {
      \ 'relative': 'cursor',
      \ 'row': 1,
      \ 'col': 0,
      \ 'width': 42,
      \ 'height': &previewheight,
      \ 'style': 'minimal',
      \ 'border': 'rounded'
      \ }

" Gundo
if has('python3')
    let g:gundo_prefer_python3 = 1
endif

" Markology
let g:markology_include='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

" Vimux
let g:VimuxPromptString = "$ "
let g:VimuxExpandCommand = 1

"Python syntax highlight
let g:python_highlight_all = 1
let g:python_highlight_indent_errors = 1
let g:python_highlight_space_errors = 0
let g:python_highlight_operators = 0

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

" vim-test
" make test commands execute using dispatch.vim
let test#strategy = 'vimux'
" let test#strategy = 'asyncrun'
" let test#strategy = 'asyncrun_background'
let test#javascript#jest#executable = 'yarn test:watch'
let test#enabled_runners = ["javascript#jest"]

" asynctasks
let g:asynctasks_term_pos = 'tmux'
let g:asynctasks_config_name = '.vim/tasks.ini'

" }}}

" PLUGIN KEYMAPS {{{
" ===================

map <C-t> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>

nmap <leader>o :Oil<CR>

nnoremap U :GundoToggle<CR>
let NERDTreeMapOpenSplit='s'
let NERDTreeMapOpenVSplit='v'
"nertree git
let g:NERDTreeGitStatusMapNextHunk=']h'
let g:NERDTreeGitStatusMapPrevHunk='[h'

" context.vim
nnoremap <F3> :<C-U>ContextToggle<CR>

" gitgutter mappings
omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
vmap <leader>ha <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>hv <Plug>(GitGutterPreviewHunk)
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>hf :GitGutterFold<CR>

"leap.nvim
" nmap s <Plug>(leap-forward)
" nmap S <Plug>(leap-backward)
" nmap gs <Plug>(leap-from-window)
"vim sneak
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T
let g:sneak#label = 1

"fugitive
function! CloseGstatus() abort
  for l:winnr in range(1, winnr('$'))
    if !empty(getwinvar(l:winnr, 'fugitive_status'))
      execute l:winnr.'close'
    endif
  endfor
endfunction
noremap <silent><leader>gs :Git\|15wincmd_<CR>
noremap <silent><F8> :Git\|15wincmd_<CR>
noremap <leader>gd :Gvdiffsplit!<CR>
noremap <leader>gl :0Gclog<CR>
noremap <leader>gL :G log --graph<CR>
vmap <leader>gl :Gclog<CR>:copen<CR>
noremap <leader>gB :Git blame<CR>
" noremap <leader>gp :AsyncRun -post=Git git push<CR>
noremap <silent><leader>gp :call asyncrun#run('', {'post':'call coc#notify#create(["git push complete"],{"title":" Git ","borderhighlight":"GruvboxGreenBold","highlight":"Normal","timeout":2000,"kind":"info"})'}, 'git push -u')<CR>
" create a popup with git info about the current line
"
if !has('nvim')
  nmap <silent><Leader>gm :call setbufvar(winbufnr(popup_atcursor(split(system("git log -n 1 -L " . line(".") . ",+1:" . expand("%:p")), "\n"), { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 })), "&filetype", "git")<CR>
else
  function! ShowGitLogForLine()
    let l:git_output = split(system('git log -n 1 -L ' . line(".") . ',+1:' . shellescape(expand("%:p"))), "\n")
    if v:shell_error != 0
      echohl ErrorMsg
      echo "Failed to execute git command:"
      echo join(l:git_output, "\n")
      echohl None
      return
    endif

    let l:buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(l:buf, 0, -1, v:false, l:git_output)
    call nvim_buf_set_option(l:buf, 'filetype', 'git')
    let l:max_line_length = max(map(l:git_output, 'strwidth(v:val)'))
    let l:width = min([l:max_line_length + 2, &columns - 4])
    let l:height = min([len(l:git_output), &lines])
    let l:opts = {
          \ 'relative': 'cursor',
          \ 'width': l:width,
          \ 'height': l:height,
          \ 'row': 1,
          \ 'col': 1,
          \ 'style': 'minimal',
          \ 'border': 'rounded',
          \ }
    call nvim_open_win(l:buf, v:true, l:opts)
  endfunction
  nnoremap <silent> <Leader>gm :call ShowGitLogForLine()<CR>
endif

" allow typing :git commands instead of :Git
" cnoreabbrev git Git

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
noremap <leader>rc :let g:asynctasks_last = ''<CR>:VimuxPromptCommand<CR>
noremap <expr> <leader>rl g:asynctasks_last != '' ? ':AsyncTaskLast<CR>' : ':VimuxRunLastCommand<CR>'
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

" vim-test
nnoremap <leader>tn :TestNearest<CR>
nnoremap <leader>tf :TestFile<CR>

" dap
if &rtp =~ 'nvim-dap' && &rtp =~ 'nvim-dap-ui' && glob("~/.vim/plugged/nvim-dap")!=#"" && glob("~/.vim/plugged/nvim-dap-ui")!=#""
  nmap <F5> :lua require('dap').continue()<CR>
  nmap <F6> :lua require('dap').terminate()<CR>
  nmap <F7> :lua require('dap').step_into()<CR>
  nmap <F8> :lua require('dap').step_over()<CR>
  nmap <F9> :lua require('dap').step_out()<CR>
  nmap <leader>iu :lua require('dapui').toggle()<CR>
  " vmap <leader>ie :lua require('dapui').eval()<CR> " not working
  nmap <leader>ik :lua require('dap.ui.widgets').hover()<CR>
  nmap <leader>B :lua require('dap').toggle_breakpoint()<CR>
  nmap <leader>bl :lua require('dap').list_breakpoints(); vim.cmd('copen')<CR>
  nmap <leader>bC :lua require('dap').clear_breakpoints()<CR>
  nmap <leader>bc :lua require('dap').set_breakpoint(vim.fn.input('Break condition: '), nil, nil)<CR>
  nmap <leader>bL :lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
endif

" }}}

" FZF {{{
" =====================

" fzf.vim {{{
if &rtp =~ 'fzf.vim' && glob("~/.vim/plugged/fzf.vim/plugin/fzf.vim")!=#""
  nmap <expr> <leader>p fugitive#Head() != '' ? ':FZFGFiles<CR>' : ':FZFFiles<CR>'
  nmap <leader>P :FZFFiles<CR>
  nmap <leader>l :FZFBuffers<CR>
  nmap <F1> :FZFBuffers<CR>
  nmap <leader>L :FZFLines<CR>
  nmap <leader>f :FZFRg<CR>
  nmap <leader>F :FZFRgWithFilenames<space>
  nmap <leader>/ :FZFHistory/<CR>
  nmap <leader>: :FZFHistory:<CR>
  nmap <leader>M :FZFMaps<CR>
  nmap <leader>m :FZFMarks<CR>
  nmap <leader>j :FZFJumps<CR>

  " coc fzf
  if &rtp =~ 'coc-fzf' && glob("~/.vim/plugged/coc-fzf")!=#""
    let g:coc_fzf_preview_toggle_key = '/'
    " let g:coc_fzf_opts = []
    let g:coc_fzf_preview = 'up'
    nnoremap <silent><nowait> <leader>kd  :<C-u>CocFzfList diagnostics<CR>
    nnoremap <silent><nowait> <leader>ke  :<C-u>CocFzfList extensions<CR>
    nnoremap <silent><nowait> <leader>kc  :<C-u>CocFzfList commands<CR>
    nnoremap <silent><nowait> <leader>ks  :<C-u>CocFzfList snippets<CR>
    nnoremap <silent><nowait> <leader>kl  :<C-u>CocFzfList outline<CR>
  endif

  " fzf-checkout
  let g:fzf_checkout_git_options = '--sort=-committerdate'
  noremap <leader>gb :FZFGBranches --locals<CR>
  noremap <leader>gt :FZFGTags<CR>
  noremap <leader>gC :FZFCommits --pretty=format:'\%C(yellow)\%h\%Creset \%C(auto)\%d\%Creset \%s (\%Cblue\%an\%Creset, \%cr)'<CR>
  noremap <leader>gc :FZFBCommits --pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s (%Cblue%an%Creset, %cr)'<CR>
  vmap <leader>gc :FZFBCommits --pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s (%Cblue%an%Creset, %cr)'<CR>

  if glob("~/.vim/plugin/fzf.vim")!=#""
    noremap <leader>gv :FZFGitEditBranchFile<CR>
    noremap <leader>gV :FZFGitEditCommitFile<CR>
    noremap <leader>rt :AsyncTaskFzf<CR>

    if exists('$TMUX')
      noremap <leader>rp :FZFVimuxPickPane<CR>
    endif

    if &rtp =~ 'nvim-dap' && &rtp =~ 'nvim-dap-ui' && glob("~/.vim/plugged/nvim-dap")!=#"" && glob("~/.vim/plugged/nvim-dap-ui")!=#""
      noremap <leader>ic :FZFDapCommand<CR>
      noremap <leader>ib :FZFDapBreakpoints<CR>
      noremap <leader>if :FZFDapFrames<CR>
    endif
  endif
endif
" }}}
" fzf-lua {{{
if &rtp =~ 'fzf-lua' && glob("~/.vim/plugged/fzf-lua/plugin/fzf-lua.lua")!=#""
  nmap <leader>F :FzfLua<CR>
  nmap <leader>R :FzfLua resume<CR>
  nmap <expr> <leader>p fugitive#Head() != '' ? ':FzfLua git_files<CR>' : ':FzfLua files<CR>'
  nmap <leader>P :FzfLua files<CR>
  nmap <leader>l :FzfLua buffers<CR>
  nmap <F1> :FzfLua buffers<CR>
  nmap <leader>L :FzfLua lines<CR>
  nmap <leader>f :FzfLua live_grep<CR>
  vmap <leader>f :FzfLua grep_visual<CR>
  nmap <leader>/ :FzfLua search_history<CR>
  nmap <leader>: :FzfLua command_history<CR>
  nmap <leader>M :FzfLua keymaps<CR>
  nmap <leader>m :FzfLua marks<CR>
  nmap <leader>j :FzfLua jumps<CR>
  nmap <leader>c :FzfLua commands<CR>
  " git
  noremap <leader>gb :FzfLua git_branches<CR>
  noremap <leader>gt :FzfLua git_tags<CR>
  noremap <leader>gc :FzfLua git_bcommits<CR>
  vmap <leader>gc :FzfLua git_bcommits<CR>
  noremap <leader>gC :FzfLua git_commits<CR>

  " lsp
  if &rtp =~ 'coc.nvim' && glob("~/.vim/plugged/coc.nvim/plugin/coc.vim")!=#""
    " these mappings are defined inside .config/nvim/lua/fzf.lua
  else
    nnoremap <silent><nowait> <leader>kd  :<C-u>FzfLua lsp_document_diagnostics<CR>
    nnoremap <silent><nowait> <leader>kD  :<C-u>FzfLua lsp_workspace_diagnostics<CR>
    nnoremap <silent><nowait> <leader>kl  :<C-u>FzfLua lsp_document_symbols<CR>
    nnoremap <silent><nowait> <leader>kL  :<C-u>FzfLua lsp_workspace_symbols<CR>
    nnoremap <silent><nowait> <leader>kr  :<C-u>FzfLua lsp_references<CR>
    nnoremap <silent><nowait> <leader>kf  :<C-u>FzfLua lsp_finder<CR>
  endif


  " dap
  noremap <leader>ic :FzfLua dap_commands<CR>
  noremap <leader>ib :FzfLua dap_breakpoints<CR>
  noremap <leader>if :FzfLua dap_frames<CR>
  noremap <leader>il :FzfLua dap_configurations<CR>
  noremap <leader>iv :FzfLua dap_variables<CR>

  noremap <leader>rt :AsyncTaskFzf<CR>
  if exists('$TMUX')
    noremap <leader>rp :FZFVimuxPickPane<CR>
  endif
endif
" }}}
" }}}

" COC {{{
" ======================

if !executable('node')
  let g:coc_start_at_startup = 0
endif

if &rtp =~ 'coc.nvim' && glob("~/.vim/plugged/coc.nvim/plugin/coc.vim")!=#""

  let g:coc_config_home = '~/.vim'
  let g:coc_disable_startup_warning = 1

  " Coc Extensions
  let g:coc_global_extensions = [
        \'coc-json',
        \'coc-docker',
        \'coc-snippets',
        \'coc-sh',
        \]

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

  " map ctrl-space to get coc completion
  if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
  else
    inoremap <silent><expr> <c-@> coc#refresh()
  endif

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>
  nnoremap <silent> <leader>K :execute '!' . &keywordprg . " " . expand('<cword>')<CR>

  " Use Ctrl l for expanding snippet
  imap <C-l> <Plug>(coc-snippets-expand)

  " Use `[d` and `]d` to navigate diagnostics
  " Use `:cocDiagnostics` to get all diagnostics of current buffer in location list.
  nmap <silent> [d <Plug>(coc-diagnostic-prev)
  nmap <silent> ]d <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gD :tab split<CR>:call CocAction('jumpDefinition')<CR>
  nmap <silent> gl <Plug>(coc-declaration)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gr <Plug>(coc-references)
  nmap <silent> gR <Plug>(coc-rename)

  noremap go :call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>
  noremap g= :call CocActionAsync('format')<CR>

  nmap <leader>ka  <Plug>(coc-codeaction-cursor)
  nmap <leader>kA  <Plug>(coc-codeaction)

  nnoremap <silent><nowait> <leader>ko  :<C-u>call CocOutlineToggle()<CR>
  nnoremap <silent><nowait> <leader>kt  :<C-u>CocToggle<CR>
  nnoremap <silent><nowait> <leader>kf  :<C-u>call CocAction('showOutgoingCalls')<CR>
  nnoremap <silent><nowait> <leader>kr  :<C-u>call CocAction('showIncomingCalls')<CR>
endif

" }}}

" GUI SPECIFIC {{{
" =================

if has("gui_running")
  colorscheme gruvbox
  let g:gruvbox_contrast_dark = 'medium'
  let g:gruvbox_contrast_light = 'soft'
  set background=dark

  set guifont=Terminess\ Nerd\ Font\ Mono\ 13
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

" list stashes on fugitive
augroup CustomFugitiveMappings
  function ListStashes()
    let l:prevheight = &previewheight
    set previewheight=4
    :Git! --paginate stash list '--pretty=format:%h %as %<(10)%gd %<(76,trunc)%s'
    let &previewheight=l:prevheight
  endfunction

  autocmd!
  autocmd FileType fugitive nmap <buffer> czl :call ListStashes()<cr>
augroup END

let g:python_recommended_style = 0
autocmd FileType python setlocal tabstop=2 shiftwidth=2 softtabstop=2 noexpandtab autoindent "because someone has too much screen space in their eyesight
autocmd FileType python setlocal indentkeys-=<:> " colon will auto indent line in insert mode, remove that behavior
autocmd FileType python setlocal indentkeys-=:

" use dart#dmt or :DartFmt to format the dart file
autocmd FileType dart setlocal formatexpr=dart#fmt()

" must be used from the first line
autocmd FileType json setlocal formatprg=python3\ -m\ json.tool

" add @ completion
autocmd FileType scss setl iskeyword+=@-@

" disable folding on output of dadbod-ui
autocmd FileType dbout setlocal nofoldenable

" enable completion on dap repl
autocmd FileType dap-repl lua require('dap.ext.autocompl').attach()

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

augroup hitablinefill
    autocmd!
    autocmd User AirlineAfterInit hi airline_tabfill ctermbg=NONE
augroup END

" }}}
