local palette = require("gruvbox").palette
require("gruvbox").setup({
  transparent_mode = true,
  contrast = 'hard',
  overrides = {
    Pmenu = { fg = palette.light1, bg = palette.dark1 },
    PmenuSel  =  { fg = palette.dark1, bg = palette.bright_blue, bold = true },

    Todo = { link = 'GruvboxYellowBold' },

    -- GitGutter
    GitGutterAdd = { link = 'GruvboxGreen' },
    GitGutterChange = { link = 'GruvboxYellow' },
    GitGutterDelete = { link = 'GruvboxRed' },
    GitGutterChangeDelete = { link = 'GruvboxYellow' },

    -- Sneak
    Sneak = { link = 'Search' },
    SneakCurrent = { link = 'IncSearch' },

    -- Markology
    MarkologyHLl = { link = 'GruvboxYellowBold' },
    MarkologyHLu = { link = 'GruvboxPurpleBold' },
    MarkologyHLm = { link = 'GruvboxOrangeBold' },

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

    ["@punctuation.bracket"] = { link = "cleared" },
    ["@punctuation.delimiter"] = { link = "cleared" },

    ["@lsp.type.function.typescript"] = { link = "cleared" },
    ["@lsp.type.parameter.typescript"] = { link = "cleared" },
    ["@lsp.type.property.typescript"] = { link = "cleared" },
    ["@lsp.typemod.property.declaration.typescript"] = { link = "GruvboxAqua" },
    ["@variable.member.typescript"] = { link = "cleared" },
    ["@attribute.typescript"] = { link = "GruvboxOrange" },

    ["@variable.parameter.bash"] = { link = "cleared" },
    ["@variable.bash"] = { link = "GruvboxBlueBold" },

    ["@string.yaml"] = { link = "cleared" },
    ["@lsp.type.parameter.dockerfile"] = { link = "cleared" },

    ["@markup.heading.gitcommit"] = { link = "cleared"},
  }
})
vim.cmd("colorscheme gruvbox")
