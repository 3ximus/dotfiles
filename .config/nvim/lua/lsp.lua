
require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python" },
})

require("mason").setup({
  ui = {
    border = "rounded",
  }
})
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer" }
})
-- vim.keymap.set("n", "<leader>gd", vim.diagnostic.open_float, {})

local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup({})
lspconfig.pyright.setup({})
lspconfig.ts_ls.setup({})
lspconfig.rust_analyzer.setup({})

-- auto setup lsp servers
-- require("mason-lspconfig").setup_handlers {
--   -- The first entry (without a key) will be the default handler
--   -- and will be called for each installed server that doesn't have
--   -- a dedicated handler.
--   function (server_name) -- default handler (optional)
--     require("lspconfig")[server_name].setup {}
--   end,
--   -- Next, you can provide a dedicated handler for specific servers.
--   -- For example, a handler override for the `rust_analyzer`:
--   -- ["rust_analyzer"] = function ()
--   --   require("rust-tools").setup {}
--   -- end
-- }

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '', -- or other icon of your choice here, this is just what my config has:
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '󰌵',
    },
  },
})
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
