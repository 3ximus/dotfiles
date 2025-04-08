-- vim: foldmethod=marker foldlevel=0

local fzf_lua = require("fzf-lua")
local actions = fzf_lua.actions
local utils = fzf_lua.utils


fzf_lua.setup({
  -- fzf_bin = "fzf-tmux",
  -- fzf_tmux_opts = { ["-p"] = "90%,70%" },
  fzf_opts = {
    ["--border"] = "rounded",
    ['--info']   = false,
    ["--layout"] = false,
    ["--tmux"]   = "center,90%,70%",
  },
  fzf_colors = {
    ["border"] = { "fg", "Comment" },
  },
  file_icon_padding = '',
  winopts = { preview = { default = "bat", border = "border-left" } },
  keymap = {
    builtin = {
      true,
      -- nvim registers <C-/> as <C-_>, use insert mode
      -- and press <C-v><C-/> should output ^_
      ["<C-_>"] = "toggle-preview",
    },
    fzf = {
      true,
      ["ctrl-/"] = "toggle-preview",
    },
  },
  actions = {
    files = {
      ["enter"] = actions.file_edit_or_qf,
      ["ctrl-s"] = actions.file_split,
      ["ctrl-v"] = actions.file_vsplit,
      ["ctrl-t"] = actions.file_tabedit,
      ["ctrl-q"] = actions.file_sel_to_qf,
      -- ["alt-l"] = actions.file_sel_to_ll,
    },
  },
  files = {
    file_icons = false, -- show file icons (true|"devicons"|"mini")?
  },
  manpages = { previewer = "man_native" },
  helptags = { previewer = "help_native" },
  lsp = {
    code_actions = {
      previewer = "codeaction_native",
      -- preview_pager = "delta --side-by-side --width=$FZF_PREVIEW_COLUMNS",
    }
  },
  tags = { previewer = "bat" },
  btags = { previewer = "bat" },
  lines = { _treesitter = false, },
  blines = { _treesitter = false },
  git = {
    files = {
      file_icons = false, -- show file icons (true|"devicons"|"mini")?
    },
    commits = {
      cmd = [[git log --color --pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s (%Cblue%an%Creset, %cr)' ]],
    },
    bcommits = {
      cmd = [[git log --color --pretty=format:'%C(yellow)%h%Creset %C(auto)%d%Creset %s (%Cblue%an%Creset, %cr)' {file}]],
    }
  },
})

fzf_lua.register_ui_select({
  fzf_opts = {
    ["--border"]         = "rounded",
    ['--info']           = false,
    ["--layout"]         = false,
    ["--tmux"]           = "center,60%,40%",
    ["--preview-window"] = "up:70%"
  },
  winopts = {
    preview = { vertical = 'up:70%' },
  }
})

-- Async Task {{{
local function async_task_fzf()
  local rows = vim.fn['asynctasks#source'](999)
  local source = {}
  for _, row in ipairs(rows) do
    local type = string.gsub(string.gsub(row[2], '<local>', 'L'), '<global>', 'G')
    table.insert(source,
      string.format("\27[1;30m%s\27[m %s \27[1;30m|  %s\27[m", vim.trim(type),
        string.gsub(row[1], '[^#]+#', "\27[1;34m%0\27[m"), row[3]))
  end

  local opts = {
    fzf_opts = {
      ["--border"]    = "rounded",
      ['--no-info']   = true,
      ["--layout"]    = false,
      ["--delimiter"] = "[| ]+",
      ["--nth"]       = "2",
      ["--tmux"]      = "center,50%,40%",
      ["--prompt"]    = "Run Task > ",
      ["--header"]    =
      ":: \27[1;33menter\27[m Run command. \27[1;33mctrl-l\27[m Type command. \27[1;33mctrl-e\27[m Edit tasks file"
    },
    actions = {
      ['default'] = function(selected, opts)
        local p1 = string.find(selected[1], '|')
        -- run task
        if p1 and p1 >= 0 then
          local name = string.match(selected[1]:sub(3, p1 - 1), '^%s*(.-)%s*$')
          if name ~= '' then
            vim.cmd("AsyncTask " .. name)
          end
        end
      end,
      ['ctrl-e'] = function(selected, opts)
        vim.cmd("AsyncTaskEdit")
      end,
      ['ctrl-l'] = function(selected, opts)
        local p1 = string.find(selected[1], '|')
        local command = string.match(selected[1]:sub(p1 + 2), '^%s*(.-)%s*$')
        if not vim.g.VimuxRunnerIndex or not string.match(vim.fn.VimuxTmux("list-panes -a -F '#{pane_id}'"), vim.g.VimuxRunnerIndex) then
          vim.fn.VimuxOpenRunner()
        end
        vim.fn.VimuxSendText(vim.trim(command) .. ' ')
        vim.fn.VimuxTmux('select-pane -t ' .. vim.g.VimuxRunnerIndex)
      end
    }
  }
  fzf_lua.fzf_exec(source, opts)
end

vim.api.nvim_create_user_command('AsyncTaskFzf', async_task_fzf, {})
-- }}}
