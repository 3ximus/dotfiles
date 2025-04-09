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
  winopts = {
    preview = {
      default = "bat",
      border = "border-left",
      layout = "horizontal",
      horizontal = "right:50%",
    }
  },
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
  grep = { winopts = { preview = { hidden = true } } },
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
  },
  winopts = {
    preview = { layout = "vertical", vertical = 'up:70%' },
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

-- Coc Stuff {{{
local api = vim.api
local fn = vim.fn
local fzf_lua = require("fzf-lua")
local fzf_lua_config = require("fzf-lua.config")
local builtin = require("fzf-lua.previewer.builtin")
local utils = require("fzf-lua.utils")
local path = require "fzf-lua.path"
local CocActionAsync = fn.CocActionAsync

local _single  = { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
local _rounded = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
local _border  = true and _rounded or _single
base_opts = {
    fzf_opts = { ["--tmux"] = false, ["--reverse"] = true, ["--border"] = false },
    winopts = {
      border  = function(_, m)
        assert(m.type == "nvim" and m.name == "fzf")
        if m.nwin == 1 then
          -- No preview, return the border whole
          return _border
        else
          -- has preview `nwim==2`
          assert(type(m.layout) == "string")
          local b = vim.deepcopy(_border)
          if m.layout == "down" then
            b[5] = "┤" -- bottom right
            b[6] = "" -- remove bottom
            b[7] = "├" -- bottom left
          elseif m.layout == "up" then
            b[1] = "├" --top right
            b[3] = "┤" -- top left
          elseif m.layout == "left" then
            b[1] = "┬" -- top left
            b[8] = "" -- remove left
            b[7] = "┴" -- bottom right
          else -- right
            b[3] = "┬" -- top right
            b[4] = "" -- remove right
            b[5] = "┴" -- bottom right
          end
          return b
        end
      end,
      preview = {
        scrollbar = "border",
        border = function(_, m)
          if m.type == "fzf" then
            -- Always return none, let `bat --style=default` to draw our border
            return "single"
          else
            assert(m.type == "nvim" and m.name == "prev" and type(m.layout) == "string")
            local b = vim.deepcopy(_border)
            if m.layout == "down" then
              b[1] = "├" --top right
              b[3] = "┤" -- top left
            elseif m.layout == "up" then
              b[7] = "├" -- bottom left
              b[6] = "" -- remove bottom
              b[5] = "┤" -- bottom right
            elseif m.layout == "left" then
              b[3] = "┬" -- top right
              b[5] = "┴" -- bottom right
            else -- right
              b[1] = "┬" -- top left
              b[7] = "┴" -- bottom left
            end
            return b
          end
        end,
        layout = "vertical",
        vertical = "up:50%"
      }
    },
}
-- local fname = path.join({ vim.g.fzf_lua_directory, "profiles", "border-fused.lua" })
-- base_opts = vim.tbl_deep_extend("force", base_opts, utils.load_profile_fname(fname, nil, true))
-- print(vim.inspect(base_opts))

local store = { results = {}, items = {} }

-- 关闭所有的浮动窗口
local function close_all_coc_floats()
  vim.api.nvim_exec(
    [[
    if coc#float#has_float() > 0
      call coc#float#close_all()
    endif
  ]],
    false
  )
end

-- 定义设置高亮的函数
local function highlight_lsp_range(bufnr, ns_id, hl_group, target)
  local function apply_highlight(range)
    local start_line = range.start.line
    local start_char = range.start.character
    local end_line = range["end"].line
    local end_char = range["end"].character

    -- 如果起始行和结束行相同，则为单行高亮
    if start_line == end_line then
      api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, start_line, start_char, end_char)
    else
      -- 否则为多行高亮
      for line = start_line, end_line do
        local col_start = (line == start_line) and start_char or 0
        local col_end = (line == end_line) and end_char or -1
        api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, line, col_start, col_end)
      end
    end
  end

  local range = target.range

  -- 如果存在 targetRange，则对 targetRange 高亮
  if target.targetRange then
    range = target.targetRange
  end

  apply_highlight(range)
end

-- 组合字符串
local function format_string(filename, lnum, col, text)
  local str = utils.ansi_from_hl("DefxIconsDefaultIcon", "| %d col %d |")
  return string.format("%s " .. str .. " %s", filename, lnum, col, text)
end

-- 分解字符串
local function parse_string(formatted_string)
  local pattern = "(.+) | (%d+) col (%d+) | (.+)"
  local extracted_filename, extracted_lnum, extracted_col, extracted_text = string.match(formatted_string, pattern)
  return extracted_filename, tonumber(extracted_lnum), tonumber(extracted_col), extracted_text
end
-- 检查 coc 是否已经初始化
local function is_ready(feature)
  if vim.g.coc_service_initialized ~= 1 then
    print("Coc is not ready!")
    return
  end

  if feature and not fn.CocHasProvider(feature) then
    print("Coc: server does not support " .. feature)
    return
  end

  return true
end

-- 获取移除 cwd 的 filename
local function get_filename(path)
  local cwd = fn.getcwd()
  if not string.match(cwd, "/$") then
    cwd = cwd .. "/"
  end
  -- 转义
  cwd = string.gsub(cwd, "([%.%-%+])", "%%%1")
  return string.gsub(path, "^" .. cwd, "")
end

-- 从 store 中获取对应的结果
local function get_target_store(string)
  -- 从 store.items 找到对应的结果，记录目标 index
  local str = utils.strip_ansi_coloring(string)
  local index = -1
  for i, item in ipairs(store.items) do
    if item.display == str then
      index = i
      break
    end
  end

  local res = {}

  res.source = store.source[index]
  res.item = store.items[index]

  return res
end

-- 把 locations 转换成 items
local locations_to_items = function(locs)
  if not locs then
    return
  end
  local items = {}
  for _, l in ipairs(locs) do
    if l.targetUri and l.targetRange then
      -- LocationLink
      l.uri = l.targetUri
      l.range = l.targetRange
    end
    local bufnr = vim.uri_to_bufnr(l.uri)
    local line = ""
    -- 判断是否真是存在的文件
    local is_file = fn.filereadable(vim.uri_to_fname(l.uri))
    if is_file == 0 then
      -- 如果不是真实存在，则 load
      fn.bufload(bufnr)
    end
    local was_buffer_previously_opend = api.nvim_buf_is_loaded(bufnr)
    if not was_buffer_previously_opend then
      -- 没有打开过 buffer，使用 fn.readfile 读取文件内容
      local content = fn.readfile(vim.uri_to_fname(l.uri))
      line = content[l.range.start.line + 1] or ""
    else
      -- 已有 buffer，使用 api.nvim_buf_get_lines 读取文件内容
      line = (api.nvim_buf_get_lines(bufnr, l.range.start.line, l.range.start.line + 1, false) or { "" })[1] or ""
    end

    -- 移除开头空格
    line = string.gsub(line, "^%s+", "")

    local filename = vim.uri_to_fname(l.uri)
    local row = l.range.start.line
    items[#items + 1] = { filename = filename, lnum = row + 1, col = l.range.start.character + 1, text = line }
  end

  return items
end

-- previewer refactor
local function getNewPreviewer(string_parser)
  local previewer = builtin.base:extend()

  -- 初始化自定义 previewer
  function previewer:new(o, opts, fzf_win)
    previewer.super.new(self, o, opts, fzf_win)
    setmetatable(self, previewer)
    return self
  end

  -- 重写 previewer 的 populate_preview_buf 方法
  function previewer:populate_preview_buf(display_str)
    local tmpbuf = self:get_tmp_buffer()

    local _, lnum, col = string_parser(display_str)

    local target = get_target_store(display_str)

    -- 判断 target 和 target.source 是否存在
    if not target or not target.source then
      -- 清空预览框并返回
      api.nvim_buf_set_lines(tmpbuf, 0, -1, false, {})
      self:set_preview_buf(tmpbuf)
      return
    end

    local uri = target.source.uri

    -- 先查询 buffer 是否已经打开，如果已经打开，读取 buffer 的内容
    -- 否则，使用 fn.readfile 读取文件内容
    local content = {}
    local filetype = ""

    local bufnr = vim.uri_to_bufnr(uri)
    local was_buffer_previously_opend = api.nvim_buf_is_loaded(bufnr)
    fn.bufload(bufnr)

    -- 打开 buffer，获取内容和 filetype，如果 buffer 已经打开，不会重复打开
    -- 获取完毕后，如果之前未打开，关闭 buffer
    content = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    filetype = api.nvim_buf_get_option(bufnr, "filetype")
    if not was_buffer_previously_opend then
      api.nvim_buf_delete(bufnr, { force = true })
    end

    -- 设置内容
    api.nvim_buf_set_lines(tmpbuf, 0, -1, false, content)
    -- 设置语法高亮
    local lcount = vim.api.nvim_buf_line_count(tmpbuf)
    local bytes = vim.api.nvim_buf_get_offset(tmpbuf, lcount)
    local max_filesize = 500 * 1024 -- 500K
    if bytes <= max_filesize then
      -- api.nvim_buf_set_option(tmpbuf, 'filetype', filetype) -- 使用 filetype 会启用 treesitter
      api.nvim_buf_set_option(tmpbuf, "syntax", filetype) -- 使用 syntax 不会启用 treesitter，用普通的语法高亮
    end
    self:set_preview_buf(tmpbuf)

    -- 设置高亮和光标位置
    pcall(api.nvim_win_call, self.win.preview_winid, function()
      -- 这个回调中 0 就是当前窗口的 编号：
      -- 相当于 local winnr = fn.bufwinid(tmpbuf) 的 winnr
      api.nvim_win_set_cursor(0, { lnum, col - 1 })
      fn.clearmatches()
      -- 高亮
      highlight_lsp_range(tmpbuf, -1, "LspReferenceText", target.source)
      self.orig_pos = api.nvim_win_get_cursor(0) -- 给 previewer:scroll() 用的原始光标位置，用于判断是否需要设置 cursorline
      utils.zz()
    end)

    self.win:update_preview_scrollbar()
  end

  return previewer
end

local function parse_symbol_string(str)
  -- format: "s [Keyword] if (true) <lnum> col <col>"
  -- 提取 lnum 和 col
  local pattern = "(.+) (%d+) col (%d+)"
  local display_str = utils.strip_ansi_coloring(str)
  local _, lnum, col = string.match(display_str, pattern)

  return "", tonumber(lnum), tonumber(col)
end

local CommonPreviewer = getNewPreviewer(parse_string)
local SymbolPreviewer = getNewPreviewer(parse_symbol_string)

-- 选中后跳转到对应的位置
local function jump_to_location(selected)
  utils.fzf_exit()
  local display_str = selected[1]
  local target = get_target_store(display_str)

  local is_file = fn.filereadable(vim.uri_to_fname(target.source.uri))
  if is_file == 0 then
    -- 如果不是真实存在，则直接打开文件
    vim.cmd("e " .. vim.uri_to_fname(target.source.uri))
    return
  end
  -- target.source.range.start 和 target.source.range["end"] 里面的值有可能是负数，修正为 0，例如 eslint_d 在遇到 git conflict 标记的时候
  if target.source.range.start.line < 0 then
    target.source.range.start.line = 0
  end
  if target.source.range.start.character < 0 then
    target.source.range.start.character = 0
  end
  if target.source.range["end"].line < 0 then
    target.source.range["end"].line = 0
  end
  if target.source.range["end"].character < 0 then
    target.source.range["end"].character = 0
  end
  vim.lsp.util.show_document(target.source, "utf-8")
  store = {}
end

-- to quickfix
local function send_selected_to_qf(selected, opts)
  local all_items = {}
  -- 如果 selected 长度只有一个，则 send 一个
  if selected and #selected ~= 1 then
    for _, str in ipairs(selected) do
      local target = get_target_store(str)
      all_items[#all_items + 1] = target.item
    end
  else
    -- all_items = store.items -- send 全部
    all_items = { store.items[1] } -- send 一个
  end
  local qf_list = {}
  local lsp_ranges = {}
  local title = string.format("[FzfLua] lsp references")

  for _, item in ipairs(all_items) do
    local target = get_target_store(item.display)
    local source = target.source
    table.insert(
      qf_list,
      { filename = get_filename(item.filename), lnum = item.lnum, col = item.col, text = item.text }
    )
    table.insert(lsp_ranges, source.range)
  end

  fn.setqflist(
    {},
    " ",
    { nr = "$", items = qf_list, title = title, context = { bqf = { lsp_ranges_hl = lsp_ranges } } }
  )
  if type(opts.copen) == "function" then
    opts.copen(selected, opts)
  elseif opts.copen ~= false then
    vim.cmd(opts.copen or "botright copen")
  end

  store = {}
end

local function CocActionWithTimeout(type, ...)
  local result = nil
  local completed = false

  local args = { ... }
  table.insert(args, 1, type)
  table.insert(args, function(_, res)
    result = res
    completed = true
  end)

  CocActionAsync(unpack(args))

  local timeout = 3000
  local waited = vim.wait(timeout, function()
    return completed
  end, 50)

  if not waited then
    vim.cmd("CocRestart")
    print("CocAction timeout, restart CoC")
  end

  return result
end

-- list_or_jump
local function list_or_jump(provider, has_jump)
  local action = provider
  store = {}
  if not is_ready() then
    return
  end

  local tables = CocActionWithTimeout(action)

  if type(tables) ~= "table" then
    return
  end

  if vim.tbl_isempty(tables) then
    print("Not found")
    return
  end
  if has_jump and #tables == 1 then
    CocActionAsync("runCommand", "workspace.openLocation", nil, tables[1])
    return
  end

  store.source = tables

  local results = locations_to_items(tables)

  if not results or vim.tbl_isempty(results) then
    return
  end

  local strings = {}

  for _, result in ipairs(results) do
    local filename = get_filename(result.filename)
    filename = utils.ansi_from_hl("Directory", filename)
    local text = utils.ansi_from_hl("Comment", result.text)

    local str = format_string(filename, result.lnum, result.col, text)
    strings[#strings + 1] = str

    result.display = utils.strip_ansi_coloring(str)
  end

  store.items = results

  local opts = {
    -- _ctor 是为了防止 fzf 内部有深拷贝，导致报错
    previewer = {
      _ctor = function()
        return CommonPreviewer
      end,
    },
    actions = { ["enter"] = jump_to_location, ["ctrl-q"] = send_selected_to_qf },
  }

  opts = vim.tbl_deep_extend("keep", base_opts, opts)
  local normalized_opts = fzf_lua_config.normalize_opts(opts, "lsp")
  normalized_opts.winopts.title_pos = nil -- 默认值是 "center"，把它移除掉，否则会最终传给 vim.api.nvim_open_win(bufnr, true, opts)，nvim_open_win 不接受 title_pos
  return fzf_lua.fzf_exec(strings, normalized_opts)
end

-- diagnostic
local function diagnostic(filter)
  store = {}

  if not is_ready() then
    return
  end

  local tables = CocActionWithTimeout("diagnosticList")

  if type(tables) ~= "table" then
    return
  end
  if filter then
    tables = filter(tables)
  end
  if vim.tbl_isempty(tables) then
    return
  end
  if filter then
    tables = filter(tables)
  end

  local source = {}

  for _, t in ipairs(tables) do
    table.insert(source, t.location)
  end

  store.source = source

  local results = locations_to_items(source)

  if not results or vim.tbl_isempty(results) then
    return
  end

  local strings = {}

  for i, result in ipairs(results) do
    local filename = get_filename(result.filename)
    filename = utils.ansi_from_hl("Comment", filename)
    local target = tables[i]
    -- 跳过 target.source 为 coc-pretty-ts-errors
    -- if target.source == "pretty-ts-errors" then
    --   goto continue
    -- end
    local severity = "[" .. target.severity .. "]"
    local message = target.message
    -- 把 \n 替换为 ↵
    message = string.gsub(message, "\n", "↵")
    if target.severity == "Error" then
      severity = utils.ansi_from_hl("ErrorMsg", severity)
      message = utils.ansi_from_hl("ErrorMsg", message)
    elseif target.severity == "Warning" then
      severity = utils.ansi_from_hl("WarningMsg", "[Warn]")
      message = utils.ansi_from_hl("WarningMsg", message)
    elseif target.severity == "Information" then
      severity = utils.ansi_from_hl("Directory", "[Info]")
      message = utils.ansi_from_hl("Directory", message)
    elseif target.severity == "Hint" then
      severity = utils.ansi_from_hl("Directory", severity)
      message = utils.ansi_from_hl("Directory", message)
    end
    -- local text = "[" .. target.source .. "] " .. severity .. " " .. target.message
    local text = "[" .. target.source .. "] " .. message .. " " .. severity
    -- 如果 result.lnum 或者 result.col 为负数或 0，则把其变为 1
    if result.lnum <= 0 then
      result.lnum = 1
    end
    if result.col <= 0 then
      result.col = 1
    end
    local str = format_string(filename, result.lnum, result.col, text)
    strings[#strings + 1] = str

    result.display = utils.strip_ansi_coloring(str)
    -- @todo: 有问题就取消这里的注释
    -- ::continue::
  end

  store.items = results
  return strings
end

local function diagnostic_from_current_buffer()
  close_all_coc_floats()
  local function filter(results)
    local current_bufnr = api.nvim_get_current_buf()
    local current_file_path = vim.uri_to_fname(vim.uri_from_bufnr(current_bufnr))
    local table = {}
    for _, result in ipairs(results) do
      if result.file == current_file_path then
        table[#table + 1] = result
      end
    end
    return table
  end

  local strings = diagnostic(filter)
  if type(strings) ~= "table" or vim.tbl_isempty(strings) then
    return
  end

  local opts = {
    -- _ctor 是为了防止 fzf 内部有深拷贝，导致报错
    previewer = {
      _ctor = function()
        return CommonPreviewer
      end,
    },
    actions = { ["enter"] = jump_to_location, ["ctrl-q"] = send_selected_to_qf },
  }

  opts = vim.tbl_deep_extend("keep", base_opts, opts)
  local normalized_opts = fzf_lua_config.normalize_opts(opts, "lsp")
  normalized_opts.winopts.title_pos = nil -- 默认值是 "center"，把它移除掉，否则会最终传给 vim.api.nvim_open_win(bufnr, true, opts)，nvim_open_win 不接受 title_pos
  fzf_lua.fzf_exec(strings, normalized_opts)
end

local function diagnostic_from_workspace()
  close_all_coc_floats()
  local strings = diagnostic()
  if type(strings) ~= "table" or vim.tbl_isempty(strings) then
    return
  end

  local opts = {
    -- _ctor 是为了防止 fzf 内部有深拷贝，导致报错
    previewer = {
      _ctor = function()
        return CommonPreviewer
      end,
    },
    actions = { ["enter"] = jump_to_location, ["ctrl-q"] = send_selected_to_qf },
  }

  opts = vim.tbl_deep_extend("keep", base_opts, opts)
  local normalized_opts = fzf_lua_config.normalize_opts(opts, "lsp")
  normalized_opts.winopts.title_pos = nil -- 默认值是 "center"，把它移除掉，否则会最终传给 vim.api.nvim_open_win(bufnr, true, opts)，nvim_open_win 不接受 title_pos
  fzf_lua.fzf_exec(strings, normalized_opts)
end

local function get_lsp_icon(kind)
  local icons = {
    Keyword = "kwrd",
    Variable = "var",
    Value = "val",
    Operator = "opr",
    Constructor = "ctor",
    Function = "func",
    Reference = "ref",
    Constant = "cnst",
    Method = "meth",
    Struct = "stru",
    Class = "clas",
    Interface = "intf",
    Text = "txt",
    Enum = "enum",
    EnumMember = "emem",
    Module = "modu",
    Color = "colr",
    Property = "prop",
    Field = "fld",
    Unit = "unit",
    Event = "evnt",
    File = "file",
    Folder = "fold",
    Snippet = "snip",
    TypeParameter = "tparam",
    Default = "deflt",
  }

  local highlight = {
    Keyword = "CocSymbolKeyword",
    Variable = "CocSymbolVariable",
    Value = "CocSymbolValue",
    Operator = "CocSymbolOperator",
    Constructor = "CocSymbolConstructor",
    Function = "CocSymbolFunction",
    Reference = "CocSymbolReference",
    Constant = "CocSymbolConstant",
    Method = "CocSymbolMethod",
    Struct = "CocSymbolStruct",
    Class = "CocSymbolClass",
    Interface = "CocSymbolInterface",
    Text = "CocSymbolText",
    Enum = "CocSymbolEnum",
    EnumMember = "CocSymbolEnumMember",
    Module = "CocSymbolModule",
    Color = "CocSymbolColor",
    Property = "CocSymbolProperty",
    Field = "CocSymbolField",
    Unit = "CocSymbolUnit",
    Event = "CocSymbolEvent",
    File = "CocSymbolFile",
    Folder = "CocSymbolFolder",
    Snippet = "CocSymbolSnippet",
    TypeParameter = "CocSymbolTypeParameter",
    Default = "CocSymbolDefault",
  }

  return utils.ansi_from_hl(highlight[kind] or highlight.Default, icons[kind] or icons.Default)
end

local function lsp_reference()
  close_all_coc_floats()
  list_or_jump("references", true)
end

local function lsp_implementation()
  close_all_coc_floats()
  list_or_jump("implementations", true)
end

local function lsp_definition()
  close_all_coc_floats()
  list_or_jump("definitions", true)
end

local function diagnostic_related_info()
  close_all_coc_floats()
  list_or_jump("diagnosticRelatedInformation", true)
end

local function get_symbols(symbols)
  local current_bufnr = api.nvim_get_current_buf()
  local uri = vim.uri_from_bufnr(current_bufnr)

  local strings = {}
  local items = {}

  for _, s in ipairs(symbols) do
    local icon = utils.ansi_from_hl("WarningMsg", get_lsp_icon(s.kind))
    local kind = utils.ansi_from_hl("DefxIconsDefaultIcon", "[" .. s.kind .. "]")
    local text = utils.ansi_from_hl("Directory", s.text)
    local position = utils.ansi_from_hl("DefxIconsDefaultIcon", s.lnum .. " col " .. s.col)
    local string = icon .. " " .. kind .. " " .. text .. " " .. position
    strings[#strings + 1] = string
    s.uri = uri
    items[#items + 1] = {
      lnum = s.lnum,
      col = s.col,
      text = s.text,
      position = utils.strip_ansi_coloring(position),
      display = utils.strip_ansi_coloring(string),
      filename = vim.uri_to_fname(s.uri),
    }
  end

  store.source = symbols
  store.items = items

  local opts = {
    previewer = {
      _ctor = function()
        return SymbolPreviewer
      end,
    },
    actions = {
      ["enter"] = jump_to_location,
      ["ctrl-q"] = send_selected_to_qf,
      ["ctrl-x"] = function(selected)
        utils.fzf_exit()
        local next_source = {}

        for _, str in ipairs(selected) do
          local target = get_target_store(str)
          table.insert(next_source, target.source)
        end

        -- 根据 next_source 里 item 的 lnum 从小到大排序
        table.sort(next_source, function(a, b)
          return a.lnum < b.lnum
        end)

        get_symbols(next_source)
      end,
    },
  }

  opts = vim.tbl_deep_extend("keep", base_opts, opts)
  local normalized_opts = fzf_lua_config.normalize_opts(opts, "lsp")
  normalized_opts.winopts.title_pos = nil -- 默认值是 "center"，把它移除掉，否则会最终传给 vim.api.nvim_open_win(bufnr, true, opts)，nvim_open_win 不接受 title_pos
  fzf_lua.fzf_exec(strings, normalized_opts)
end

local function symbol()
  close_all_coc_floats()
  store = {}
  if not is_ready("documentSymbol") then
    return
  end

  local current_buf = api.nvim_get_current_buf()
  -- this needs a prompt
  -- local symbols = CocActionWithTimeout("getWorkspaceSymbols", current_buf)
  local symbols = CocActionWithTimeout("documentSymbols", current_buf)
  if type(symbols) ~= "table" or vim.tbl_isempty(symbols) then
    return
  end

  get_symbols(symbols)
end

-- wk.register({ mode = { "n" }, ["gd"] = { lsp_definition, "Go to definitions" } })
-- wk.register({ mode = { "n" }, ["gD"] = { diagnostic_related_info, "Go to diagnostic related information" } })
-- wk.register({ mode = { "n" }, ["gi"] = { lsp_implementation, "Go to implementations" } })
vim.keymap.set("n", "<leader>kd", diagnostic_from_current_buffer, {})
vim.keymap.set("n", "<leader>kD", diagnostic_from_workspace, {})
vim.keymap.set("n", "<leader>kl", symbol, {})
vim.keymap.set("n", "<leader>kr", lsp_reference, {})
-- }}}
