" vim: foldmethod=marker foldlevel=0

" VUNDLE PLUGINS {{{
" ===================

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

Plugin 'VundleVim/Vundle.vim'

Plugin 'vim-airline/vim-airline'
Plugin 'scrooloose/nerdtree'

" GIT
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'
" Plugin 'rhysd/git-messenger.vim'
Plugin 'godlygeek/tabular'

" TOOLS
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'sjl/gundo.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'unblevable/quick-scope'
Plugin 'AndrewRadev/linediff.vim'
" Plugin 'ctrlpvim/ctrlp.vim'
Plugin '3ximus/fzf' " use my fork to allow passing g:fzf_no_term
Plugin 'junegunn/fzf.vim'

Plugin 'junegunn/vim-peekaboo'
" Plugin 'Yilin-Yang/vim-markbar'
Plugin 'jeetsukumaran/vim-markology'

" COMPLETION
Plugin 'neoclide/coc.nvim'

" TMUX CLIPBOARD SHARING
Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'roxma/vim-tmux-clipboard'

Plugin 'preservim/vimux'

" EXTRA SYNTAX HIGHLIGHT
Plugin 'justinmk/vim-syntax-extra'
Plugin 'PProvost/vim-ps1'
Plugin 'vim-python/python-syntax'
Plugin 'MTDL9/vim-log-highlighting'
Plugin 'dart-lang/dart-vim-plugin'

" EXTRAS
Plugin 'mattn/emmet-vim'

" COLORSCHEME
Plugin 'morhetz/gruvbox'

" OTHER
Plugin 'mhinz/vim-startify'
"absolute numbers when window looses focus
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
"auto folds
Plugin 'benknoble/vim-auto-origami'
"search popup, only supported in vim >8.2.0896
"Plugin 'obcat/vim-hitspop' "airline already doest this...
Plugin 'machakann/vim-highlightedyank'
" Profiler
Plugin 'dstein64/vim-startuptime'

"NerdFont icons in NerdTree, startify and Ctrl-p
Plugin 'ryanoasis/vim-devicons'

call vundle#end()
filetype plugin indent on

" }}}

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
set ts=4 "number of spaces in a tab
set sw=4 "number of spaces for indent
set softtabstop=0 noexpandtab
set autoindent
set smartindent
set smarttab
"set expandtab "tabs are spaces, aka cancer
"setlocal lcs=tab:>-,trail:-,eol:¬ list! " use list mode mapped to F2 when vim is opened

set updatetime=400

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
    set foldmethod=indent
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

let s:hidden_all = 0
function! ToggleHiddenAll()
    if s:hidden_all == 0
        let s:hidden_all = 1
        set showtabline=0
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showtabline=2
        set showmode
        set ruler
        set laststatus=2
        set showcmd
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

" change buffers
nmap <C-P> :bp<CR>
nmap <C-N> :bn<CR>

nmap <C-W>n :tabnext<CR>
nmap <C-W>p :tabprevious<CR>
nmap <C-W>N :tabnew<CR>

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
nmap zF :call Fold(1)<CR>:set foldmethod=manual<CR>

" display line endings and tabs
nnoremap <F2> :<C-U>setlocal lcs=tab:>-,trail:-,eol:¬ list! list? <CR>
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

" remove trailing whitespaces
nmap <leader>s :call StripTrailingWhitespace()<CR>
nnoremap <leader><Tab> :call TabSpaceToogle()<CR>
" map hide terminal elements
nnoremap <leader>a :call ToggleHiddenAll()<CR>

" save and load view of files
nmap <leader>vs :mkview<CR>
nmap <leader>vl :loadview<CR>

" jump forward and backward in quickfix results
noremap ]q :cnext<CR>
noremap [q :cprevious<CR>

" create a popup with git info about the current line
nmap <silent><Leader>gm :call setbufvar(winbufnr(popup_atcursor(split(system("git log -n 1 -L " . line(".") . ",+1:" . expand("%:p")), "\n"), { "padding": [1,1,1,1], "pos": "botleft", "wrap": 0 })), "&filetype", "git")<CR>

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

" " Markbar
" highlight link markbarContextMarkHighlight GruvboxRedBold
" highlight link markbarSectionLowercaseMark GruvboxYellowBold
" highlight link markbarSectionUppercaseMark GruvboxPurpleBold
" highlight link markbarSectionBrackets GruvboxFg1

" Coc
highlight link CocErrorSign GruvboxRedBold
highlight link CocWarningSign GruvboxYellowBold
highlight link CocInfoSign GruvboxPurpleBold

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

"setup airline
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
let g:airline#extensions#hunks#enabled=0
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

"this will only worked with patched fonts from NERD FONTS
let g:airline_left_sep = "\uE0B8"
let g:airline_right_sep = "\uE0BA"

let g:airline_left_alt_sep = "\uE0B9"
let g:airline_right_alt_sep =  "\uE0BB"

"CtrlP
if &rtp =~ 'ctrlp.vim' && glob("~/.vim/bundle/ctrlp.vim/plugin/ctrlp.vim")!=#""
    let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
endif

" FZF
if &rtp =~ 'fzf.vim' && glob("~/.vim/bundle/fzf.vim/plugin/fzf.vim")!=#""
    let g:fzf_command_prefix = 'FZF'

    let g:fzf_no_term = 1
    let g:fzf_layout = { 'down': '30%' }
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

    let g:fzf_action = {
        \ 'ctrl-q': function('s:build_quickfix_list'),
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-x': 'split',
        \ 'ctrl-v': 'vsplit' }
endif


"NERDTree
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''
let g:NERDTreeMinimalUI=1
let g:NERDTreeCreatePrefix='silent keepalt keepjumps'
let g:NERDTreeShowLineNumbers=1
let g:NERDTreeWinSize=30

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
let g:webdevicons_enable_airline_statusline = 1
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:DevIconsEnableDistro = 0

"Auto Origami (auto manage fold columns)
if &rtp =~ 'vim-auto-origami' && glob("~/.vim/bundle/vim-auto-origami/plugin/auto_origami.vim")!=#""
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

"Python syntax highlight
let g:python_highlight_all = 1
let g:python_highlight_indent_errors = 1
let g:python_highlight_space_errors = 0
let g:python_highlight_operators = 0

" Gundo
if has('python3')
    let g:gundo_prefer_python3 = 1
endif

" Markology
let g:markology_include='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

" " Markbar
" let g:markbar_mark_marker = '>'
" " let g:markbar_set_default_peekaboo_mappings = v:false
" let g:markbar_explicitly_remap_mark_mappings = v:true
" let g:markbar_peekaboo_marks_to_display = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
" let g:markbar_marks_to_display = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

" quick-scope
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" hitspop
let g:hitspop_line = 'winbot'
" let g:hitspop_line_mod = 1

let g:VimuxPromptString = "$ "

" }}}

" PLUGIN KEYMAPS {{{
" ===================

map <C-t> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>
nnoremap U :GundoToggle<CR>

nmap <leader>' <Plug>ToggleMarkbar

if &rtp =~ 'ctrlp.vim' && glob("~/.vim/bundle/ctrlp.vim/plugin/ctrlp.vim")!=#""
    let g:ctrlp_map = '<leader>p'
    nmap <leader>b :CtrlPBuffer<CR>
elseif &rtp =~ 'fzf.vim' && glob("~/.vim/bundle/fzf.vim/plugin/fzf.vim")!=#""
    nmap <leader>p :FZFFiles<CR>
    nmap <leader>b :FZFBuffers<CR>
    nmap <leader>l :FZFLines<CR>
    nmap <leader>f :FZFAg<CR>
endif

omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)
" <leader>hs is the default for staging
vmap <leader>ha <Plug>(GitGutterStageHunk)
nmap <leader>ha <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>hv <Plug>(GitGutterPreviewHunk)
nmap <leader>hn <Plug>(GitGutterNextHunk)
nmap <leader>hp <Plug>(GitGutterPrevHunk)
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>hf :GitGutterFold<CR>

"nertree git
let g:NERDTreeGitStatusMapNextHunk=']h'
let g:NERDTreeGitStatusMapPrevHunk='[h'

noremap <leader>gs :Git<CR>
noremap <leader>gc :Git commit<CR>
noremap <leader>ge :Gedit<CR>
noremap <leader>gd :Git diff<CR>
noremap <leader>gl :0Gclog<CR>:copen<CR>
noremap <leader>gld :Gclog -- %<CR>:copen<CR>
noremap <leader>gla :Gclog<CR>:copen<CR>
noremap <leader>gb :Git branch<CR>
noremap <leader>gB :Git blame<CR>
noremap <leader>gp :Git push<CR>

" Line diff
noremap <leader>D :LinediffReset<CR>
noremap <leader>d :Linediff<CR>

" Emmet mappings
nmap <leader>tt :Emmet<space>
let g:user_emmet_leader_key='<leader>t'
let g:user_emmet_mode='nv'

"Vimux
noremap <leader>rc  :VimuxPromptCommand<CR>
noremap <leader>rl  :VimuxRunLastCommand<CR>
noremap <leader>rk  :VimuxInterruptRunner<CR>
noremap <leader>rq  :VimuxCloseRunner<CR>
noremap <leader>ro  :VimuxOpenRunner<CR>
noremap <leader>ri  :VimuxInspectRunner<CR>
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
if isdirectory(expand("~/.vim/bundle/tabular"))
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

" COC CONFIGURATION {{{
" ======================

if &rtp =~ 'coc.nvim' && glob("~/.vim/bundle/coc.nvim/plugin/coc.vim")!=#""
    " let g:coc_start_at_startup = 0

    let g:coc_disable_startup_warning = 1

    " Coc Extensions
    let g:coc_global_extensions = [
          \'coc-python',
          \'coc-json',
          \'coc-sh',
          \]

    " other extensions
          " \'coc-angular',
          " \'coc-tsserver',
          " \'coc-clangd',
          " \'coc-flutter-tools',

    inoremap <silent><expr> <c-@> coc#refresh()

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Use K to show documentation in preview window.
    nnoremap <silent> K :call <SID>show_documentation()<CR>
    nnoremap <silent> <leader>K :execute '!' . &keywordprg . " " . expand('<cword>')<CR>

    function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
        elseif (coc#rpc#ready())
            call CocActionAsync('doHover')
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

    " Add Vim's native statusline support.
    " NOTE: Please see `:h coc-status` for integrations with external plugins that
    " provide custom statusline: vim-airline.
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

    " Mappings for CoCList
    " Show all diagnostics.
    nnoremap <silent><nowait> <leader>cd  :<C-u>CocList diagnostics<CR>
    " Manage extensions.
    nnoremap <silent><nowait> <leader>ce  :<C-u>CocList extensions<CR>
    " Show commands.
    nnoremap <silent><nowait> <leader>cc  :<C-u>CocList commands<CR>
    " Find symbol of current document.
    nnoremap <silent><nowait> <leader>co  :<C-u>CocList outline<CR>
    nnoremap <silent><nowait> <leader>ca  :<C-u>CocAction<CR>
    " Search workspace symbols.
    nnoremap <silent><nowait> <leader>cs  :<C-u>CocList -I symbols<CR>
    " Do default action for next item.
    nnoremap <silent><nowait> <leader>cj  :<C-u>CocNext<CR>
    " Do default action for previous item.
    nnoremap <silent><nowait> <leader>ck  :<C-u>CocPrev<CR>
    " Resume latest coc list.
    nnoremap <silent><nowait> <leader>cp  :<C-u>CocListResume<CR>
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

autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab autoindent "because someone has too much screen space in their eyesight
autocmd FileType python setlocal indentkeys-=<:> " colon will auto indent line in insert mode, remove that behavior
autocmd FileType python setlocal indentkeys-=:

" use dart#dmt or :DartFmt to format the dart file
autocmd FileType dart setlocal formatexpr=dart#fmt()

" must be used from the first line
autocmd FileType json setlocal formatprg=python3\ -m\ json.tool

" add @ completion
autocmd FileType scss setl iskeyword+=@-@

" }}}

" RUN COMMANDS ON EVENTS {{{
" ===========================

" autocmd VimEnter * call ToggleHiddenAll()

" assumes set noignorecase
augroup dynamic_smartcase
    autocmd!
    autocmd CmdLineEnter : set ignorecase
    autocmd CmdLineLeave : set noignorecase
augroup END

" fix artifacts on screen from tmux-focus-events
autocmd FocusGained * silent redraw!
" autocmd FocusLost * silent redraw!

" }}}
