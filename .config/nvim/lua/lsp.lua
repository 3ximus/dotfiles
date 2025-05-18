---@diagnostic disable: undefined-global

vim.diagnostic.config({
  virtual_text = {
    prefix = '●', -- Could be '■', '▎', 'x'
  },
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

vim.keymap.set("n", "<leader>kt", function()
  vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
end)
vim.keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", {})
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {})
vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", {})
vim.keymap.set("n", "<leader>ka", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "gR", vim.lsp.buf.rename, {})
vim.keymap.set("n", "g=", vim.lsp.buf.format, {})
vim.keymap.set("n", "<leader>ko", vim.lsp.buf.outgoing_calls, {})
vim.keymap.set("n", "<leader>ki", vim.lsp.buf.incoming_calls, {})
vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, {})

-- float options
local border = { { '┌', 'LineNr' }, { '─', 'LineNr' }, { '┐', 'LineNr' }, { '│', 'LineNr' }, { '┘', 'LineNr' }, { '─', 'LineNr' }, { '└', 'LineNr' }, { '│', 'LineNr' } }
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or border
  opts.max_width = opts.max_width or 80
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

require('nvim-treesitter.configs').setup({
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "go", "css", "html", "dockerfile" },
  sync_install = false,
  auto_install = true,
  highlight = { enable = true },
  -- additional_vim_regex_highlighting = true,
})
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.opt.foldlevel = 99

require("mason").setup({ ui = { border = "rounded" } })
require("mason-lspconfig").setup({ automatic_enable = false })

local function install_mason_lsp_servers(servers)
  local mason_lspconfig_status_ok, lsp_installer = pcall(require, "mason-lspconfig")
  local mason_status_ok, _ = pcall(require, "mason")
  if mason_lspconfig_status_ok and mason_status_ok then
    lsp_installer.setup({ ensure_installed = servers })
  end
end

local function setup_lsps(servers, settings)
  local lspconfig = require("lspconfig")
  for _, k in ipairs(servers) do
    local opts = {}
    if settings[k] ~= nil then
      opts = vim.tbl_deep_extend("force", settings[k], opts)
    end
    lspconfig[k].setup({})
  end
end

local servers = {
  "lua_ls",
  "pyright",
  "ts_ls",
  "rust_analyzer",
  "gopls",
  "bashls",
  "clangd",
  "dockerls"
}
local settings = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
      }
    }
  }
}

install_mason_lsp_servers(servers)
setup_lsps(servers, settings)

require('blink.cmp').setup({
  keymap = { preset = 'enter' },
  completion = {
    documentation = { auto_show = true },
    trigger = { show_on_insert_on_trigger_character = true },
    menu = {
      draw = {
        -- We don't need label_description now because label and label_description are already
        -- combined together in label by colorful-menu.nvim.
        -- treesitter = { 'lsp' },
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
  -- fuzzy = { implementation = "lua" },
})
require("colorful-menu").setup({})


-- auto float when about to call a function
vim.api.nvim_create_autocmd("InsertCharPre", {
  callback = function()
    local char = vim.v.char
    if char == "(" then
      vim.defer_fn(function()
        vim.lsp.buf.signature_help()
      end, 0)
    end
  end,
})

-- automatically show float when hovering diagnostic
vim.api.nvim_create_autocmd({ "CursorHold" }, {
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= '' then
        -- There's already a floating window open, so don't open another
        return
      end
    end
    vim.diagnostic.open_float()
  end
})
