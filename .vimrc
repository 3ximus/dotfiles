
" ----------------------------
" Vundle
" ----------------------------

set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle
call vundle#rc()

Plugin 'gmarik/vundle'
Plugin 'vim-airline/vim-airline'
Plugin 'scrooloose/nerdtree'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
Plugin 'sjl/gundo.vim'
Plugin 'wincent/command-t'
Plugin 'easymotion/vim-easymotion'
Plugin 'junegunn/goyo.vim'

Plugin 'PProvost/vim-ps1'
Plugin 'vim-python/python-syntax'

Plugin 'benknoble/vim-auto-origami' "auto folds

Plugin 'morhetz/gruvbox'

call vundle#end()
filetype plugin indent on

" ----------------------------
" General Options
" ----------------------------

let mapleader=","

"encoding
set encoding=utf-8

"use X clipboard as default
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
autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab autoindent "because someone has too much screen space in their eyesight
"set expandtab "tabs are spaces, aka cancer
"setlocal lcs=tab:>-,trail:-,eol:¬ list! " use list mode mapped to F2 when vim is opened

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

"enable mouse on insert mode
"if has ("mouse")
" set mouse=i
"endif


" To diable bell sounds, specially on windows
set noerrorbells visualbell t_vb=



" ----------------------------
" Functions
" ----------------------------

"fold function to auto fold entire document based on indent
function! Fold(depth)
	let &foldnestmax = a:depth
	set foldmethod=indent
endfunction
command! -nargs=1 Fold :call Fold( '<args>' ) "command to use Fold function

"remove trailing whitespaces
function StripTrailingWhitespace()
	if !&binary && &filetype != 'diff'
		normal mz
		normal Hmy
		%s/\s\+$//e
		normal 'yz<CR>
		normal `z
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

" Show or hide foldcolumn when folds if there are folds present
function UpdateFoldColumn()
	function! HasFoldsInner()
		let origline=line('.')
		:norm zk
		if origline==line('.')
			:norm zj
			if origline==line('.')
				return 0
			else
				return 1
			endif
		else
			return 1
		endif
		return 0
	endfunction
	let l:winview=winsaveview() "save window and cursor position
	let foldsexist=HasFoldsInner()
	if foldsexist
		set foldcolumn=1
	else
		if line('.')!=1
			:norm [z
			:norm k
		else
			:norm ]z
			:norm j
		endif
		let foldsexist=HasFoldsInner()
		if foldsexist
			set foldcolumn=1
		else
			set foldcolumn=0
		endif
	end
	call winrestview(l:winview) "restore window/cursor position
endfunction

" -----------------------------
" Keymaps
" -----------------------------

" change buffers
nmap <C-P> :bp<CR>
nmap <C-N> :bn<CR>
" remap completion
if has("gui_running")
	" C-Space seems to work under gVim on both Linux and win32
	inoremap <C-Space> <C-n>
else " no gui
	inoremap <Nul> <C-n>
endif

" run macro saved to q
nnoremap <Space> @q

" move line
nnoremap <C-j> :<C-U>m .+1<CR>
nnoremap <C-k> :<C-U>m .-2<CR>
inoremap <C-j> <Esc>:m .+1<CR>gi
inoremap <C-k> <Esc>:m .-2<CR>gi
vnoremap <C-j> :m '>+1<CR>gv
vnoremap <C-k> :m '<-2<CR>gv

"use xclip
vnoremap <leader>y :w !xclip -selection clipboard<CR><CR>
nnoremap <leader>yy :w !xclip -selection clipboard<CR><CR>

" fold with fold nest max of 1
nmap <leader>fa :call Fold(1)<CR>:set foldmethod=manual<CR>
" remove trailing whitespaces
nmap <leader>s :call StripTrailingWhitespace()<CR>
nnoremap <leader><Tab> :call TabSpaceToogle()<CR>
" display line endings and tabs
nnoremap <F2> :<C-U>setlocal lcs=tab:>-,trail:-,eol:¬ list! list? <CR>
" map hidde terminal elements
nnoremap <leader>a :call ToggleHiddenAll()<CR>

" -----------------------------
" Color Scheme
" -----------------------------

if has("gui_running")
	colo gruvbox
	let g:gruvbox_contrast_dark = 'medium'
	let g:gruvbox_contrast_light = 'soft'
	set background=dark
else
	set t_Co=256 "terminal color range
	color gruvbox
	let g:gruvbox_termcolors = 16 "256 colors look really bad
	set background=dark
	"trasparent background
	hi Normal ctermbg=none
	highlight NonText ctermbg=none
endif
hi CursorLineNr ctermbg=none


" -----------------------------
" GUI Specific
" -----------------------------

"set gui options
if has("gui_running")
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


" -----------------------------
" Plugins
" -----------------------------

"setup airline
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t' "show only file names on buffer names
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
	let g:airline_symbols.branch = ''
	"let g:airline_symbols.linenr = 'ln'
	let g:airline_symbols.whitespace = ''
else
	" powerline symbols
	let g:airline_left_sep = ''
	let g:airline_left_alt_sep = ''
	let g:airline_right_sep = ''
	let g:airline_right_alt_sep = ''
	let g:airline_symbols.branch = ''
	let g:airline_symbols.readonly = ''
	let g:airline_symbols.linenr = ''
endif

"NERDTree
"open on startup even if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" auto close vim if only nerdtree is open
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"arrow symbols
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
"let g:NERDTreeIndicatorMapCustom = {
"	\ "Modified"	: "*",
"	\ "Staged"		: "+",
"	\ "Untracked"   : "-",
"	\ "Renamed"		: "->",
"	\ "Unmerged"	: "!=",
"	\ "Deleted"		: "x",
"	\ "Dirty"		: "~",
"	\ "Clean"		: "v",
"	\ "Unknown"		: "?"
"	\ }

"GitGutter
if !has("gui_running") "running on console
	highlight clear SignColumn
	highlight GitGutterAdd ctermfg=green
	highlight GitGutterChange ctermfg=blue
	highlight GitGutterDelete ctermfg=red
	highlight GitGutterChangeDelete ctermfg=blue
endif

"Goyo
let g:goyo_width = 80
let g:goyo_height= '100%'
let g:goyo_linenr = 0


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

" ---------------------
" Plugin Keymaps
" ---------------------

map <C-t> :NERDTreeToggle<CR>
nnoremap U :GundoToggle<CR>
nnoremap <C-g> :Goyo<CR>:hi Normal ctermbg=none<CR>
nmap <leader>ha <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>hv <Plug>(GitGutterPreviewHunk)
nmap <leader>hn <Plug>(GitGutterNextHunk)
nmap <leader>hp <Plug>(GitGutterPrevHunk)
nnoremap <silent> <C-b> :CommandTMRU<CR>

" ---------------------
" RUN COMMAND ON EVENTS
" ---------------------

autocmd VimEnter * call ToggleHiddenAll()
