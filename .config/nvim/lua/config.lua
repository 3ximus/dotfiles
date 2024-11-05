-- NVIM CONFIG

vim.api.nvim_set_hl(0, 'FloatBorder', {ctermbg=0, ctermfg=12, bold=true})
vim.api.nvim_set_hl(0, 'NormalFloat', {bg=0})

-- Safelly require modules, if they don't exist nothing happens
local function prequire(m)
  local ok, err = pcall(require, m)
  if not ok then return nil, err end
  return err
end

prequire("_lualine")

local oil = prequire("oil")
if oil then
  oil.setup({
      columns = { "icon", "permissions", "size", },
    })
end

prequire("dap-debugging")
