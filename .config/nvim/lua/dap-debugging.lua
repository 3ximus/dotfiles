-- vim: foldmethod=marker foldlevel=0
local dap = require("dap")

-- use Esc to close the dap-float window type
vim.api.nvim_create_autocmd("FileType", {
    pattern = "dap-float",
    callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", "<Esc>", "<cmd>close!<CR>", { noremap = true, silent = true })
    end
})

local dapui = require("dapui")
dapui.setup({
    --               
  controls = { icons = { pause = "󰏤 F5", continue = " F5", step_into = " F7", step_over = " F8", step_out = " F9" , terminate = " F6"} },
})

-- disable completion for dap-repl
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dap-repl",
  callback = function()
    vim.bo.omnifunc = ""
  end
})

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
-- dap.listeners.before.event_terminated.dapui_config = function()
--   dapui.close()
-- end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
-- •⦁⬤⬣
vim.fn.sign_define('DapBreakpoint', { text='⬣', texthl='DapBreakpointSymbol', linehl='DapBreakpointSymbol', numhl='DapBreakpointSymbol' })
vim.fn.sign_define('DapBreakpointCondition', { text='', texthl='DapBreakpointSymbol', linehl='DapBreakpointSymbol', numhl='DapBreakpointSymbol' })
vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DapBreakpointSymbol', linehl='DapBreakpointSymbol', numhl= 'DapBreakpointSymbol' })
vim.fn.sign_define('DapLogPoint', { text='', texthl='DapUIBreakpointsInfo', linehl='DapUIBreakpointsInfo', numhl= 'DapUIBreakpointsInfo' })
vim.fn.sign_define('DapStopped', { text='', texthl='DapStoppedSymbol', linehl='DapStoppedSymbol', numhl= 'DapStoppedSymbol' })
vim.cmd('hi clear WinBarNC')

-- javascript/typescript node {{{

-- require("dap-vscode-js").setup({
--   -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
--   debugger_path = "/home/eximus/.vim/plugged/vscode-js-debug", -- Path to vscode-js-debug installation.
--   -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
--   adapters = { 'pwa-node' }, -- which adapters to register in nvim-dap
-- })

dap.adapters['pwa-node'] = {
  type = 'server',
  host = 'localhost',
  port = '${port}',
  executable = {
    command = 'ts-node',
    args = { vim.fn.expand('$HOME/.vim/plugged/vscode-js-debug/dist/src/dapDebugServer.js'), '${port}', },
  },
}

for _, language in ipairs({ "typescript", "javascript" }) do
  require("dap").configurations[language] = {
    {
      name = "Attach",
      type = "pwa-node",
      request = "attach",
      cwd = "${workspaceFolder}",
    },
    {
      name = "Jest",
      type = "pwa-node",
      request = "launch",
      runtimeExecutable = "node",
      runtimeArgs = {"${workspaceFolder}/node_modules/.bin/jest", "--runInBand"},
      args = function () return vim.fn.input({ prompt = "Jest Arguments: ", default = "" }) end,
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
    },
  }
end
-- }}}

-- python {{{
require("dap-python").setup("python3")
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    console = 'integratedTerminal'
  },
  {
    type = 'python',
    request = 'launch',
    name = 'Pick file',
    console = 'integratedTerminal',
    program = function()
      local sel = vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
        source = "find . -type f -name '*.py' ! -path '*/venv/*' ! -path '*/.venv/*' ! -path '*/env/*'",
        sink = function(file) print(file) end
      }))
      return sel[#sel] and sel[#sel] or dap.ABORT
    end
  },
}
-- }}}

-- lldb + rust {{{
require("dap-lldb").setup({
  {
    name = "rust",
    type = "lldb",
    request = "launch",
    program = function()
      local cwd = vim.fn.getcwd()

      -- Try to get package name from Cargo.toml
      local file = io.open(cwd .. "/Cargo.toml", "r")
      if file then
        local content = file:read("*all")
        file:close()
        local package_name = content:match('%[package%].-name%s*=%s*["\']([^"\']+)["\']')
        if package_name then
          local binary = cwd .. "/target/debug/" .. package_name
          if vim.loop.fs_stat(binary) then
            return binary
          end
        end
      end

      -- Fallback: find any executable in target/debug
      local handle = io.popen("find " .. cwd .. "/target/debug -maxdepth 1 -type f -executable 2>/dev/null | head -1")
      if handle then
        local result = handle:read("*all"):gsub("\n", "")
        handle:close()
        if result ~= "" then
          return result
        end
      end

      vim.notify("No debug binary found", vim.log.levels.WARN)
      return cwd .. "/target/debug/main"
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
})
-- }}}
