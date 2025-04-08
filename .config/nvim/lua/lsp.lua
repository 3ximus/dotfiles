---@diagnostic disable: undefined-global

vim.diagnostic.config({
  virtual_text = true,
  float = { source = "always" },
  signs = true,
  underline = true,
  update_in_insert = false,
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '#', -- or other icon of your choice here, this is just what my config has:
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
  },
})

-- vim.keymap.set("n", "<leader>l", vim.diagnostic.open_float, {})
vim.keymap.set("n", "<leader>kt", function()
  vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
end)

vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", {})
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", {})
vim.keymap.set("n", "<leader>ka", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "g=", vim.lsp.buf.format, {})

require('nvim-treesitter.configs').setup({
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "go" },
})

require("mason").setup({
  ui = { border = "rounded" }
})
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "gopls" }
})

local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup({})
lspconfig.pyright.setup({})
lspconfig.ts_ls.setup({})
lspconfig.rust_analyzer.setup({})
lspconfig.gopls.setup({})

require('blink.cmp').setup({
  keymap = { preset = 'enter' },
  completion = {
    documentation = { auto_show = true },
    trigger = { show_on_insert_on_trigger_character = true },
    menu = {
      draw = {
        -- We don't need label_description now because label and label_description are already
        -- combined together in label by colorful-menu.nvim.
        treesitter = { 'lsp' },
        -- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
        components = {
          label = {
            text = function(ctx)
              return require("colorful-menu").blink_components_text(ctx)
            end,
            highlight = function(ctx)
              return require("colorful-menu").blink_components_highlight(ctx)
            end,
          },
        },
      },
    },
  },
  fuzzy = { implementation = "prefer_rust" },
})
require("colorful-menu").setup({})

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
