-- NVIM CONFIG

-- Safelly require modules, if they don't exist nothing happens
local function prequire(m) 
  local ok, err = pcall(require, m) 
  if not ok then return nil, err end
  return err
end

local oil = prequire("oil")
if oil then 
  oil.setup({
      columns = {
        "icon",
        "permissions",
        "size",
        -- "mtime",
      },
    })
end

-- require'nvim-treesitter.configs'.setup {
--   highlight = { enable = true },
--   indent = { enable = true }
-- }

-- require("dap").adapters["pwa-node"] = {
--   type = "server",
--   host = "localhost",
--   port = "${port}",
--   executable = {
--     command = "node",
--     -- 💀 Make sure to update this path to point to your installation
--     args = {"/home/eximus/downloads/js-debug/src/dapDebugServer.js", "${port}"},
--   }
-- }

-- require("dap").configurations.typescript = {
--   {
--     name = "Launch file",
--     type = "pwa-node",
--     request = "attach",
--     program = "${file}",
--     runtimeExecutable = "yarn",
--     runtimeArgs = {
--       "start:debug",
--     },
--     cwd = "${workspaceFolder}",
--   },
-- }
