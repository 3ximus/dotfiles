local palette = require("gruvbox").palette
require("gruvbox").setup({
  transparent_mode = true,
  contrast = 'hard',
  overrides = {
    Todo = { link = 'GruvboxYellowBold' },

    -- GitGutter
    GitGutterAdd = { link = 'GruvboxGreen' },
    GitGutterChange = { link = 'GruvboxYellow' },
    GitGutterDelete = { link = 'GruvboxRed' },
    GitGutterChangeDelete = { link = 'GruvboxYellow' },

    -- Sneak
    Sneak = { link = 'Search' },
    SneakCurrent = { link = 'CurSearch' },
    SneakScope = { link = 'CurSearch' },
    SneakLabelMask = { link = 'LineNr' },
    SneakLabel= { link = 'Search' },

    -- Markology
    MarkologyHLl = { link = 'GruvboxYellowBold' },
    MarkologyHLu = { link = 'GruvboxPurpleBold' },
    MarkologyHLm = { link = 'GruvboxOrangeBold' },

    -- Oil
    OilDir = { link = 'GruvboxBlueBold' },
    OilDirIcon = { link = 'GruvboxBlueBold' },

    -- Coc
    CocErrorSign = { link = 'GruvboxRedBold' },
    CocWarningSign = { link = 'GruvboxYellowBold' },
    CocInfoSign = { link = 'GruvboxPurpleBold' },
    CocHintSign = { link = 'GruvboxBlueBold' },
    CocMarkdownLink =  { link = 'GruvboxBlueBold' }, -- Should push this upstream

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
