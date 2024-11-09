-- vim: foldmethod=marker foldlevel=0

-- Gruvbox theme {{{
local colors = {
  zero         = 0,
  black        = '#282828',
  white        = 15,
  red          = 1,
  aqua         = 14,
  green        = 10,
  blue         = 12,
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
    a = { bg = colors.blue, fg = colors.black, gui = 'bold' },
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
-- Custom Filename Component {{{
local custom_fname = require('lualine.components.filename'):extend()
local highlight = require'lualine.highlight'
local default_status_colors = { saved = colors.lightgray, modified = colors.blue }

function custom_fname:init(options)
  custom_fname.super.init(self, options)
  self.status_colors = {
    saved = highlight.create_component_highlight_group(
      {fg = default_status_colors.saved}, 'filename_status_saved', self.options),
    modified = highlight.create_component_highlight_group(
      {fg = default_status_colors.modified, gui = 'bold'}, 'filename_status_modified', self.options),
  }
  if self.options.color == nil then self.options.color = '' end
end

function custom_fname:update_status()
  local data = custom_fname.super.update_status(self)
  data = highlight.component_format_highlight(vim.bo.modified
                                              and self.status_colors.modified
                                              or self.status_colors.saved) .. data
  return data
end
-- }}}

require("lualine").setup({
  options = {
    icons_enabled = false,
    theme = gruvbox_theme,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = false,
    always_show_tabline = false,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {{  'mode', fmt = function(str) return str:sub(1,1) end }},
    lualine_b = {
      'branch',
      {'diagnostics', sections = { 'error', 'warn', 'info', 'hint' }}
    },
    lualine_c = {
      {
        custom_fname,
        file_status = true,
        newfile_status = true,
        path = 1,
        symbols = {
          modified = '+',
          readonly = '[RO]',
          unnamed = '[No Name]',
          newfile = '[New]',
        }
      },
      {'b:coc_current_function', color = { fg = colors.green, gui = 'bold' }}
    },
    lualine_x = {'filetype'},
    lualine_y = {'searchcount'},
    lualine_z = {'progress','location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'progress', 'location'},
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
  extensions = {'quickfix', 'oil', 'fugitive', 'nerdtree'}
})
