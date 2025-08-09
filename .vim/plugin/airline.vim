" AIRLINE CONFIGURATION

if &rtp =~ 'vim-airline' && glob("~/.vim/plugged/vim-airline/plugin/airline.vim")!=#""
  let g:airline_powerline_fonts=1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#show_close_button = 0
  let g:airline#extensions#tabline#tab_nr_type = 0 " # of splits
  let g:airline#extensions#tabline#tabnr_formatter = 'tabnr'
  let g:airline#extensions#tabline#show_tab_type = 0
  let g:airline#extensions#tabline#overflow_marker = '…'
  let g:airline#extensions#tabline#fnamemod = ':p:.'
  let g:airline#extensions#tabline#fnamecollapse = 1
  let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  " let g:airline#extensions#tabline#show_buffers = 0
  " let g:airline#extensions#tabline#tab_min_count = 2
  " let g:airline#extensions#tabline#ignore_bufadd_pat = '!|defx|gundo|nerd_tree|startify|tagbar|term://|undotree|vimfiler'

  let g:airline#extensions#whitespace#mixed_indent_algo = 1
  let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]' "hide encoding if its utf8
  let g:airline#extensions#hunks#enabled = 0
  let g:airline#extensions#hunks#non_zero_only = 1
  let g:airline#extensions#term#enabled = 0

  " coc airline configuration
  let g:airline#extensions#coc#error_symbol = ' '
  let g:airline#extensions#coc#warning_symbol = ' '
  let g:airline#extensions#coc#show_coc_status = 0 " handled in custom section
  let g:airline#extensions#coc#stl_format_err = '%C' " can use %L for line number
  let g:airline#extensions#coc#stl_format_warn = '%C'
  let g:airline#extensions#searchcount#enabled = 0 " handled in custom section

  let g:airline#extensions#default#layout = [['a', 'b', 'c', 'd'], ['x', 'y', 'z', 'warning', 'error']]

  " call airline#parts#define('coc_status_symbol', { 'raw': '%#__restore__#%{get(g:, "coc_status", "") != "" ? (get(g:, "coc_enabled", "") == 1 ? "" : "" ) : ""}'})
  " call airline#parts#define('coc_status', { 'raw': ' %{airline#util#shorten(trim(get(g:, "coc_status", "")), 100, 6)}'})
  " call airline#parts#define('coc_function',  {'raw': '%{get(b:,"coc_current_function","") != "" ? ((get(g:, "coc_status", "") != "" ? "  " : "").get(b:,"coc_current_function","")) : ""}'})
  call airline#parts#define('coc_function_clean',  {'raw': '%{get(b:,"coc_current_function","")}', 'accent':'bold'})
  call airline#parts#define('max_line', { 'raw': '%L', 'accent': 'bold'})
  call airline#parts#define('new_search_count', { 'raw': '%{v:hlsearch ? trim(airline#extensions#searchcount#status()) : ""}', 'accent': 'bold'})
  call airline#parts#define('filename_path',  {'raw': '%<%{fnamemodify(expand("%:p:h"), ":~:.:g")}/'})
  call airline#parts#define('filename',  {'raw': '%<%t%m', 'accent':'bold'})

  let g:airline_section_c = airline#section#create(['filename_path', 'filename', 'readonly'])
  let g:airline_section_e = airline#section#create(['coc_status_symbol', 'coc_function'])
  let g:airline_section_d = airline#section#create(['coc_function_clean'])
  let g:airline_section_x = airline#section#create(['%{airline#util#wrap(airline#parts#filetype(),140)}'])
  let g:airline_section_y = airline#section#create(['%{airline#util#wrap(airline#parts#ffenc(),0)}', 'new_search_count'])
  let g:airline_section_z = airline#section#create(['%p%% %l/', 'max_line', ':%c'])

  " set color on custom sections
  " autocmd User AirlineAfterTheme let g:airline#themes#gruvbox#palette.normal.airline_w = ['#282828', '#8ec07c', 0, 14]
  autocmd User AirlineAfterTheme let g:airline#themes#gruvbox#palette.normal.airline_d = ['#ebdbb2', '#282828', 2, 0]
  " autocmd User AirlineAfterTheme let g:airline#themes#gruvbox#palette.normal.airline_e = ['#ebdbb2', '#458588', 0, 14]
  " autocmd User AirlineAfterTheme let g:airline#themes#gruvbox#palette.normal.airline_b = ['#ebdbb2', '#282828', 3, 236]
  " autocmd User AirlineAfterTheme let g:airline#themes#gruvbox#palette.normal.airline_c = ['#ebdbb2', '#282828', 8, 0]

  " Hide/show tabline modes depending on open buffer list
  function! Tablineshowhide()
    let l:nbuf = len(airline#extensions#tabline#buflist#list())
    if l:nbuf == 1
      set showtabline=0
    else
      set showtabline=2
    endif
  endfunction

  augroup tablinechange
    autocmd!
    autocmd BufEnter * call Tablineshowhide()
  augroup END

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
  let g:airline_symbols.branch = ''
endif
