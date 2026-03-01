vim.api.nvim_set_hl(0, "OilExecutable", { link= 'GruvboxGreenBold' })
require("oil").setup({
  columns = { "permissions", "size" },
  view_options = { show_hidden = true },
  -- constrain_cursor = "name",
  use_default_keymaps = false,
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["gv"] = { "actions.select", opts = { vertical = true } },
    ["gs"] = { "actions.select", opts = { horizontal = true } },
    ["gt"] = { "actions.select", opts = { tab = true } },
    ["gp"] = "actions.preview",
    ["gx"] = "actions.open_external",
    ["gr"] = "actions.refresh",
    ["q"] = { "actions.close", mode = "n" },
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["zs"] = { "actions.change_sort", mode = "n" },
    ["zh"] = { "actions.toggle_hidden", mode = "n" },
  },
  view_options = {
    highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
      if entry.type == "file" then
        local oil = require("oil")
        local path = oil.get_current_dir() .. entry.name
        local stat = vim.loop.fs_stat(path)
        if stat and bit.band(stat.mode, 73) > 0 then
          return "OilExecutable"
        end
      end
      return nil
    end,
  },
})
