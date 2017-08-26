
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
set foldcolumn=1

"syntax and indentation
syntax on
syntax enable
set ts=4 "number of spaces in a tab
set sw=4 "number of spaces for indent
set autoindent
set smartindent
set smarttab
"set expandtab "tabs are spaces
"setlocal lcs=tab:>-,trail:-,eol:$ list! " use list mode mapped to F2 when vim is opened

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

"enable mouse on insert mode
"if has ("mouse")
" set mouse=i
"endif

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

" move line
nnoremap <C-j> :<C-U>m .+1<CR>
nnoremap <C-k> :<C-U>m .-2<CR>
inoremap <C-j> <Esc>:m .+1<CR>gi
inoremap <C-k> <Esc>:m .-2<CR>gi
vnoremap <C-j> :m '>+1<CR>gv
vnoremap <C-k> :m '<-2<CR>gv

" fold with fold nest max of 1
nmap <leader>fa :call Fold(1)<CR>:set foldmethod=manual<CR>
" remove trailing whitespaces
nmap <leader>s :call StripTrailingWhitespace()<CR>
" map Goyo distraction free mode
nnoremap <C-g> :Goyo<CR>:hi Normal ctermbg=none<CR>
" display line endings and tabs
nnoremap <F2> :<C-U>setlocal lcs=tab:>-,trail:-,eol:$ list! list? <CR>

" -----------------------------
" Color Scheme
" -----------------------------

if has("gui_running")
	colo gruvbox
	let g:gruvbox_contrast_dark = 'soft'
	let g:gruvbox_contrast_light = 'soft'
	set background=dark
else
	set t_Co=256 "terminal color range
	color hybrid
	"color gruvbox
	set background=dark
	"trasparent background
	hi Normal ctermbg=none
	highlight NonText ctermbg=none
endif


" -----------------------------
" GUI Specific
" -----------------------------

"set gui options
if has("gui_running")
	"set guifont=Liberation\ Mono\ for\ Powerline\ 9 " normal
	set guifont=Roboto\ Mono\ for\ Powerline\ Regular\ 9
	"set guifont=monofur\ for\ Powerline\ Regular\ 11 " funny
	"set guifont=Source\ Code\ Pro\ for\ Powerline\ Medium\ 9
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
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t' "show only file names on buffer names
let g:airline#extensions#whitespace#mixed_indent_algo = 1
if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
if !has("gui_running") "running on console
	" unicode symbols
	let g:airline_left_sep = ''
	let g:airline_right_sep = ''
	let g:airline_left_alt_sep = ''
	let g:airline_right_alt_sep = ''
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

"setup NERDTree
map <C-t> :NERDTreeToggle<CR>
"open on startup even if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" auto close vim if only nerdtree is open
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"arrow symbols
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
"git NERDTree plugin
"let g:NERDTreeIndicatorMapCustom = {
"	\ "Modified"	: "*",
"	\ "Staged"		: "+",
"	\ "Untracked" : "-",
"	\ "Renamed"		: "->",
"	\ "Unmerged"	: "!=",
"	\ "Deleted"		: "x",
"	\ "Dirty"		: "~",
"	\ "Clean"		: "v",
"	\ "Unknown"		: "?"
"	\ }

"Goyo
let g:goyo_width = 90
let g:goyo_height= '90%'
let g:goyo_linenr = 0

" config Gitgutter
nmap <Leader>ha <Plug>GitGutterStageHunk
nmap <Leader>hu <Plug>GitGutterRevertHunk
nmap <Leader>hv <Plug>GitGutterPreviewHunk

