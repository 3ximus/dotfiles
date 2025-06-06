require("oil").setup({
  columns = { "ctime", "permissions", "size" },
  view_options = {
    show_hidden = false,
  },
  constrain_cursor = "name",
  use_default_keymaps = false,
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["gv"] = { "actions.select", opts = { vertical = true } },
    ["gs"] = { "actions.select", opts = { horizontal = true } },
    ["gt"] = { "actions.select", opts = { tab = true } },
    ["gp"] = "actions.preview",
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = "actions.refresh",
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["zs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["zh"] = { "actions.toggle_hidden", mode = "n" },
  },
})
