-- NVIM CONFIG

vim.api.nvim_set_hl(0, 'FloatBorder', {ctermbg=0, ctermfg=12, bold=true})
vim.api.nvim_set_hl(0, 'NormalFloat', {bg=0})

-- Safelly require modules, if they don't exist nothing happens
local function prequire(m)
  local ok, err = pcall(require, m)
  if not ok then return nil, err end
  return err
end


local palette = require("gruvbox").palette
require("gruvbox").setup({
  transparent_mode = true,
  overrides = {
    Todo = { link = 'GruvboxYellowBold' },

    -- GitGutter
    GitGutterAdd = { link = 'GruvboxGreen' },
    GitGutterChange = { link = 'GruvboxYellow' },
    GitGutterDelete = { link = 'GruvboxRed' },
    GitGutterChangeDelete = { link = 'GruvboxYellow' },

    -- Markology
    MarkologyHLl = { link = 'GruvboxYellowBold' },
    MarkologyHLu = { link = 'GruvboxPurpleBold' },
    MarkologyHLm = { link = 'GruvboxOrangeBold' },

    -- Coc
    CocErrorSign = { link = 'GruvboxRedBold' },
    CocWarningSign = { link = 'GruvboxYellowBold' },
    CocInfoSign = { link = 'GruvboxPurpleBold' },
    CocHintSign = { link = 'GruvboxBlueBold' },

    -- Dap
    DapBreakpointSymbol = { fg = palette.bright_red, bg = palette.dark0 },
    DapStoppedSymbol = { fg = palette.bright_green, bg = palette.dark0 },
    DapUIPlayPause = { link = "GruvboxBlue" },
    DapUIRestart = { link = "GruvboxBlue" },
    DapUIStepBack = { link = "GruvboxBlue" },
    DapUIStepInto = { link = "GruvboxBlue" },
    DapUIStepOut = { link = "GruvboxBlue" },
    DapUIStepOver = { link = "GruvboxBlue" },
    DapUIStop = { link = "GruvboxRed" },
  }
})
vim.cmd("colorscheme gruvbox")

prequire("statusline")

local oil = prequire("oil")
if oil then
  oil.setup({
      columns = { "icon", "permissions", "size", },
    })
end

require("dap-debugging")
