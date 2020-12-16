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

" TOOLS
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'sjl/gundo.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'rhysd/clever-f.vim'
Plugin 'AndrewRadev/linediff.vim'
Plugin 'ctrlpvim/ctrlp.vim'

Plugin 'junegunn/vim-peekaboo'
Plugin 'Yilin-Yang/vim-markbar'
Plugin 'jeetsukumaran/vim-markology'

" COMPLETION
Plugin 'neoclide/coc.nvim'
" Plugin 'davidhalter/jedi-vim'

" TMUX CLIPBOARD SHARING
Plugin 'tmux-plugins/vim-tmux-focus-events'
Plugin 'roxma/vim-tmux-clipboard'

" EXTRA SYNTAX HIGHLIGHT
Plugin 'justinmk/vim-syntax-extra'
Plugin 'PProvost/vim-ps1'
Plugin 'vim-python/python-syntax'
Plugin 'MTDL9/vim-log-highlighting'

" COLORSCHEME
Plugin 'morhetz/gruvbox'

" OTHER
Plugin 'mhinz/vim-startify'
"absolute numbers when window looses focus
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
"auto folds
Plugin 'benknoble/vim-auto-origami'
"improved incremental search
Plugin 'osyo-manga/vim-anzu'
Plugin 'machakann/vim-highlightedyank'

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

set cmdheight=2

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

"autocomplete vim commands
set wildmenu
set wildmode=longest:list,full


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
color gruvbox
let g:gruvbox_termcolors = 16 "256 colors look really bad
set background=dark
" makes the background be this color so that when reversed for the airline
" mode foreground it stays FUCKING BLACK!!
hi Normal ctermbg=236
"trasparent background
autocmd VimEnter * highlight Normal ctermbg=none
" highlight NonText ctermbg=none
" highlight CursorLineNr ctermbg=none

" }}}

" HIGHLIGHT REDEFINITIONS {{{
" ============================

"GitGutter
highlight clear SignColumn
highlight link GitGutterAdd GruvboxGreenBold
highlight link GitGutterChange GruvboxBlueBold
highlight link GitGutterDelete GruvboxRedBold
highlight link GitGutterChangeDelete GruvboxBlueBold

" Markology
highlight link MarkologyHLl GruvboxYellowBold
highlight link MarkologyHLu GruvboxPurpleBold
highlight link MarkologyHLm GruvboxOrangeBold

" Markbar
highlight link markbarContextMarkHighlight GruvboxRedBold
highlight link markbarSectionLowercaseMark GruvboxYellowBold
highlight link markbarSectionUppercaseMark GruvboxPurpleBold
highlight link markbarSectionBrackets GruvboxFg1

" Coc
highlight link CocErrorSign GruvboxRedBold
highlight link CocWarningSign GruvboxYellowBold

if !has('gui_running')
	" Highlighted Yank
	highlight HighlightedyankRegion cterm=reverse gui=reverse

	highlight link logLevelInfo GruvboxBlueBold
endif

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
function StripTrailingWhitespace()
	if !&binary && &filetype != 'diff'
		normal m'
		%s/\s\+$//e
		normal `'
	endif
endfunction

function! ConvertToTabs(tabsize)
	let &tabstop = a:tabsize
	set noexpandtab
	%retab!
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
" nnoremap <Space> @q
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

" }}}

" PLUGIN CONFIGURATION {{{
" =========================

"setup airline
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':p:.' "show only file names on buffer names
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline#extensions#tabline#fnamecollapse = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#whitespace#mixed_indent_algo = 1
if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
if !has("gui_running") "running on console
	" unicode symbols
	" let g:airline_left_sep = ''
	" let g:airline_right_sep = ''
	" let g:airline_left_alt_sep = ''
	" let g:airline_right_alt_sep = ''
	" let g:airline_symbols.branch = ''
	" let g:airline_symbols.linenr = 'ln'
	" let g:airline_symbols.whitespace = ''
endif

"NERDTree
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

"nerdtree-git
let g:NERDTreeGitStatusConcealBrackets = 1 " default: 0
" let g:NERDTreeGitStatusShowClean = 1 " default: 0
" let g:NERDTreeGitStatusShowIgnored = 1 " a heavy feature may cost much more time. default: 0
" let g:NERDTreeGitStatusIndicatorMapCustom = {
"	\ "Modified"	: "*",
"	\ "Staged"		: "+",
"	\ "Untracked"	: "-",
"	\ "Renamed"		: "->",
"	\ "Unmerged"	: "!=",
"	\ "Deleted"		: "x",
"	\ "Dirty"		: "~",
"	\ "Clean"		: "v",
"	\ "Unknown"		: "?"
"	\ }

"Auto Origami (auto manage fold columns)
augroup auto_origami
	au!
	au CursorHold,BufWinEnter,WinEnter * AutoOrigamiFoldColumn
augroup END
let g:auto_origami_foldcolumn = 1

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

" Markbar
let g:markbar_mark_marker = '➜'
" let g:markbar_set_default_peekaboo_mappings = v:false
let g:markbar_explicitly_remap_mark_mappings = v:true
let g:markbar_peekaboo_marks_to_display = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
let g:markbar_marks_to_display = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

" clever-f
let g:clever_f_mark_direct=1

" }}}

" PLUGIN KEYMAPS {{{
" ===================

map <C-t> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>
nnoremap U :GundoToggle<CR>

nmap <leader>m <Plug>ToggleMarkbar

nmap n <Plug>(anzu-n)
nmap N <Plug>(anzu-N)
nmap * <Plug>(anzu-star)
nmap # <Plug>(anzu-sharp)

let g:ctrlp_map = '<leader>p'
nmap <leader>b :CtrlPBuffer<CR>

nmap <leader>ha <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>hv <Plug>(GitGutterPreviewHunk)
nmap <leader>hn <Plug>(GitGutterNextHunk)
nmap <leader>hp <Plug>(GitGutterPrevHunk)

noremap <leader>gs :Gstatus<CR>
noremap <leader>gc :Gcommit<CR>
noremap <leader>ge :Gedit<CR>
noremap <leader>gd :Gdiff<CR>
noremap <leader>gl :Glog<CR>
noremap <leader>gb :Gblame<CR>

noremap <leader>D :LinediffReset<CR>
noremap <leader>d :Linediff<CR>

" }}}

" COC CONFIGURATION {{{
" ======================

" Coc Extensions
let g:coc_global_extensions = [
	  \'coc-python',
	  \'coc-clangd',
	  \'coc-json',
	  \'coc-sh',
	  \]

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
nnoremap <silent><nowait> <leader>cd  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <leader>ce  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <leader>cc  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <leader>co  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <leader>cs  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <leader>cj  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <leader>ck  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <leader>cp  :<C-u>CocListResume<CR>

" }}}

" GUI SPECIFIC {{{
" =================

if has("gui_running")
	colo gruvbox
	let g:gruvbox_contrast_dark = 'medium'
	let g:gruvbox_contrast_light = 'soft'
	set background=dark

	"set guifont=Liberation\ Mono\ for\ Powerline\ 9 " normal
	"set guifont=Roboto\ Mono\ for\ Powerline\ Regular\ 9
	"set guifont=monofur\ for\ Powerline\ Regular\ 11 " funny
	set guifont=Source\ Code\ Pro\ for\ Powerline\ Medium\ 9
	"set guifont=Fira\ Mono\ for\ Powerline\ 9

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
" }}}

" RUN COMMANDS ON EVENTS {{{
" ===========================

" autocmd VimEnter * call ToggleHiddenAll()
" }}}
