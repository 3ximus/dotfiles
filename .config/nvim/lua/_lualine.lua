-- vim: foldmethod=marker foldlevel=0

-- Gruvbox theme {{{
local colors = {
  zero         = 0,
  black        = '#282828',
  white        = 15,
  red          = 1,
  lightred     = 9,
  yellow       = 3,
  aqua         = 14,
  green        = 10,
  blue         = 4,
  lightblue    = 12,
  orange       = 208,
  gray         = 8,
  darkgray     = 239,
  lightgray    = 7,
}

local gruvbox_theme = {
  normal = {
    a = { bg = colors.lightgray, fg = colors.black, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.white },
    c = { bg = colors.black, fg = colors.lightgray },
  },
  insert = {
    a = { bg = colors.lightblue, fg = colors.black, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.white },
    c = { bg = colors.black, fg = colors.lightgray },
  },
  visual = {
    a = { bg = colors.orange, fg = colors.black, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.white },
    c = { bg = colors.black, fg = colors.lightgray },
  },
  replace = {
    a = { bg = colors.green, fg = colors.black, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.white },
    c = { bg = colors.black, fg = colors.lightgray },
  },
  command = {
    a = { bg = colors.aqua, fg = colors.black, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.white },
    c = { bg = colors.black, fg = colors.lightgray },
  },
  inactive = {
    a = { bg = colors.darkgray, fg = colors.lightgray, gui = 'bold' },
    b = { bg = colors.darkgray, fg = colors.lightgray },
    c = { bg = colors.black, fg = colors.lightgray },
  },
}
-- }}}
-- Trailing Spaces Component {{{
local function trailing_spaces()
  local space = vim.fn.search([[\s\+$]], 'nwc', 0, 200)
  return space ~= 0 and "󱁐" or ""
end
-- }}}
-- Mixed Indent Component {{{
local function mixed_indent()
  local space_pat = [[\v^ +]]
  local tab_pat = [[\v^\t+]]
  local space_indent = vim.fn.search(space_pat, 'nwc')
  local tab_indent = vim.fn.search(tab_pat, 'nwc')
  local mixed = (space_indent > 0 and tab_indent > 0)
  local mixed_same_line
  if not mixed then
    mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], 'nwc')
    mixed = mixed_same_line > 0
  end
  if not mixed then return '' end
  if mixed_same_line ~= nil and mixed_same_line > 0 then
     return 'MI:'..mixed_same_line
  end
  local space_indent_cnt = vim.fn.searchcount({pattern=space_pat, max_count=1e3}).total
  local tab_indent_cnt =  vim.fn.searchcount({pattern=tab_pat, max_count=1e3}).total
  if space_indent_cnt > tab_indent_cnt then
    return 'MI:'..tab_indent
  else
    return 'MI:'..space_indent
  end
end
-- }}}

require("lualine").setup({
  options = {
    icons_enabled = false,
    theme = gruvbox_theme,
    section_separators = '',
    component_separators = '',
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = false,
    always_show_tabline = false,
    globalstatus = false,
    refresh = {
      statusline = 400,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {{ 'mode', fmt = function(str) return str:sub(1,1) end }},
    lualine_b = { 'branch' },
    lualine_c = {
      {'%<%{fnamemodify(expand("%:p:h"), ":~:.:g")}/',
        padding = { right = 0 , left = 1},
        color = function() return vim.bo.modified and {fg = colors.lightblue, gui = ''} or {fg = colors.lightgray, gui = ''} end },
      {'%<%t%m',
        padding = { left = 0 , right = 1},
        color = function() return vim.bo.modified and {fg = colors.lightblue, gui = 'bold'} or {fg = colors.lightgray, gui = 'bold'} end },
      {'b:coc_current_function',
        separator = { left = '', right = ''},
        padding = 0,
        color = { fg = colors.black, bg = colors.blue, gui = 'bold' }}
    },
    lualine_x = {'filetype',
      {'diagnostics',
        sections = { 'error', 'warn', 'info', 'hint' },
        -- symbols = { error = '', warn = '', info = '' },
        symbols = { error = '', warn = '', info = '', hint = '' },
        diagnostics_color = {
          error = { bg = colors.lightred, fg = colors.black, gui = 'bold' },
          warn = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
          info = { bg = colors.aqua, fg = colors.black, gui = 'bold' },
          hint = { bg = colors.blue, fg = colors.black, gui = 'bold' },
        },
      },
    },
    lualine_y = {'searchcount'},
    lualine_z = {
      -- 'progress',
      -- 'location',
      '%p%% %l/%L:%c',
      -- {'%p%% %l/', color = { fg=colors.black, gui='none' }, padding = { left = 1 }},
      -- {'%L:', color = { fg=colors.black, gui='bold' }, padding = 0},
      -- {'%c', color = { fg=colors.black, gui='none' }, padding = { left = 0 }},
      { trailing_spaces, color = { bg = colors.orange, fg = colors.black, gui='bold' }},
      { mixed_indent, color = { bg = colors.yellow, fg = colors.black, gui='bold' }}
    }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'%p%% %l/%L:%c'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {
      {
        'windows' ,
        symbols = { modified = ' +', alternate_file = '', directory =  '' },
        disabled_buftypes = { 'quickfix', 'prompt', 'nerdtree' },
        -- I can use cond = some function that determines visibility of this component (for example number of open buffers)
      }
    },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {{ 'tabs', mode = 2, symbols = { modified = '+', } }}
  },
  extensions = {'quickfix', 'oil', 'fugitive', 'nerdtree', 'nvim-dap-ui'}
})
