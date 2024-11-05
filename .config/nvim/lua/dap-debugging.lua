local dap = require("dap")

vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F6>', function() require('dap.ui.widgets').hover() end)
vim.keymap.set('n', '<F7>', function() require('dap').terminate() end)
vim.keymap.set('n', '<F8>', function() require('dap').step_over() end)
-- vim.keymap.set('n', '<F9>', function() require('dap').step_into() end)
-- vim.keymap.set('n', '<F10>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>bl', function() require('dap').list_breakpoints(); vim.cmd('copen') end)
vim.keymap.set('n', '<Leader>bC', function() require('dap').clear_breakpoints() end)
vim.keymap.set('n', '<Leader>bc', function() require('dap').set_breakpoint(vim.fn.input('Break condition: '), nil, nil) end)
vim.keymap.set('n', '<Leader>bL', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)

-- use Esc to close the dap-float window type
vim.api.nvim_create_autocmd("FileType", {
    pattern = "dap-float",
    callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", "<Esc>", "<cmd>close!<CR>", { noremap = true, silent = true })
    end
})

local dapui = require("dapui")
dapui.setup({
  controls = { icons = { pause = "󰏤", } },
})

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end


require("dap-vscode-js").setup({
  -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
  debugger_path = "/home/eximus/.vim/plugged/vscode-js-debug", -- Path to vscode-js-debug installation.
  -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
  adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
})

for _, language in ipairs({ "typescript", "javascript" }) do
  require("dap").configurations[language] = {
    {
      name = "Attach node",
      type = "pwa-node",
      request = "attach",
      cwd = "${workspaceFolder}",
    }
  }
end
