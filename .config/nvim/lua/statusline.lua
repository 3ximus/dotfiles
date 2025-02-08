-- vim: foldmethod=marker foldlevel=0

-- Colorscheme {{{
local colors = require('gruvbox').palette
local gruvbox_theme = {
  normal = {
    a = { bg = colors.light4, fg = colors.dark0, gui = 'bold' },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark0, fg = colors.light4 },
  },
  insert = {
    a = { bg = colors.bright_blue, fg = colors.dark0, gui = 'bold' },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark0, fg = colors.light4 },
  },
  visual = {
    a = { bg = colors.bright_orange, fg = colors.dark0, gui = 'bold' },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark0, fg = colors.light4 },
  },
  replace = {
    a = { bg = colors.bright_green, fg = colors.dark0, gui = 'bold' },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark0, fg = colors.light4 },
  },
  command = {
    a = { bg = colors.bright_aqua, fg = colors.dark0, gui = 'bold' },
    b = { bg = colors.dark2, fg = colors.light1 },
    c = { bg = colors.dark0, fg = colors.light4 },
  },
  inactive = {
    a = { bg = colors.dark2, fg = colors.light4, gui = 'bold' },
    b = { bg = colors.dark2, fg = colors.light4 },
    c = { bg = colors.dark0, fg = colors.light4 },
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
        color = function() return vim.bo.modified and {fg = colors.bright_blue, gui = ''} or {fg = colors.light4, gui = ''} end },
      {'%<%t%m',
        padding = { left = 0 , right = 1},
        color = function() return vim.bo.modified and {fg = colors.bright_blue, gui = 'bold'} or {fg = colors.light1, gui = 'bold'} end },
      {'b:coc_current_function',
        separator = { left = '', right = ''},
        padding = 0,
        color = { fg = colors.dark0, bg = colors.neutral_blue, gui = 'bold' }}
    },
    lualine_x = {
      {
        function() return require("dap").status() end,
        separator = { left = '', right = ''},
        padding = 0,
        color = { fg = colors.dark0, bg = colors.neutral_green, gui = 'bold' },
        cond = function()
          if not package.loaded.dap then return false end
          local session = require("dap").session()
          return session ~= nil
        end },
      { 'filetype', cond = function() return vim.fn.winwidth(0) > 100 end },
      {'diagnostics',
        sections = { 'error', 'warn', 'info', 'hint' },
        -- symbols = { error = '', warn = '', info = '' },
        symbols = { error = '', warn = '', info = '', hint = '' },
        diagnostics_color = {
          error = { bg = colors.bright_red, fg = colors.dark0, gui = 'bold' },
          warn = { bg = colors.bright_yellow, fg = colors.dark0, gui = 'bold' },
          info = { bg = colors.bright_aqua, fg = colors.dark0, gui = 'bold' },
          hint = { bg = colors.neutral_blue, fg = colors.dark0, gui = 'bold' },
        },
      },
    },
    lualine_y = {'searchcount'},
    lualine_z = {
      -- 'progress',
      -- 'location',
      '%p%% %l/%L:%c',
      -- {'%p%% %l/', color = { fg=colors.dark0, gui='none' }, padding = { left = 1 }},
      -- {'%L:', color = { fg=colors.dark0, gui='bold' }, padding = 0},
      -- {'%c', color = { fg=colors.dark0, gui='none' }, padding = { left = 0 }},
      { trailing_spaces, color = { bg = colors.bright_orange, fg = colors.dark0, gui='bold' }},
      { mixed_indent, color = { bg = colors.bright_yellow, fg = colors.dark0, gui='bold' }}
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
