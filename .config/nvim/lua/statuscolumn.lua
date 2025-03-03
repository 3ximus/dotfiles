-- vim: foldmethod=marker foldlevel=0

local builtin = require("statuscol.builtin")

require("statuscol").setup({
  relculright = true,
  segments = {
    -- Fold
    { text = { "%C" } },
    -- Git
    {
      sign = {
        name = { "GitGutter.*" },
        maxwidth = 1,
        colwidth = 1,
        wrap = true,
        foldclosed = true,
        fillchar = "",
      }
    },
    -- COC + DAP + Marks
    {
      sign = {
        name = { "Dap.*", "Coc.*", "ShowMark.*", ".*" },
        maxwidth = 1,
        colwidth = 1,
        foldclosed = true,
        fillchar = " ", -- make sure it's always there
      }
    },
    -- Line Numbers
    {
      text = {
        function(args)
          local lnum = args.rnu and (args.relnum > 0 and args.relnum or (args.nu and args.lnum or 0)) or args.lnum
          local pad = (' '):rep(args.nuw - #tostring(lnum))
          return "%="..pad..lnum
        end,
        " ",
      },
      -- text = { builtin.lnumfunc, " " },
      condition = { true, builtin.not_empty },
      hl = "FoldColumn", -- TODO find a way to get highlight coc/dap but not gutter
    }
  },
})
