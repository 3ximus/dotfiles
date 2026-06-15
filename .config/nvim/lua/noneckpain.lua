require("no-neck-pain").setup({
    width = 200,
    autocmds = {
        skipEnteringNoNeckPainBuffer = false,
    },
    -- Creates mappings for you to easily interact with the exposed commands.
    ---@type table
    mappings = {
        -- When `true`, creates all the mappings that are not set to `false`.
        ---@type boolean
        enabled = true,
        -- Sets a global mapping to Neovim, which allows you to toggle the plugin.
        -- When `false`, the mapping is not created.
        ---@type string
        toggle = "<Leader>np",
        -- Sets a global mapping to Neovim, which allows you to toggle the left side buffer.
        -- When `false`, the mapping is not created.
        ---@type string
        toggleLeftSide = "<Leader>nql",
        -- Sets a global mapping to Neovim, which allows you to toggle the right side buffer.
        -- When `false`, the mapping is not created.
        ---@type string
        toggleRightSide = "<Leader>nqr",
        -- Sets a global mapping to Neovim, which allows you to increase the width (+5) of the main window.
        -- When `false`, the mapping is not created.
        ---@type string | { mapping: string, value: number }
        widthUp = "<Leader>n=",
        -- Sets a global mapping to Neovim, which allows you to decrease the width (-5) of the main window.
        -- When `false`, the mapping is not created.
        ---@type string | { mapping: string, value: number }
        widthDown = "<Leader>n-",
        -- Sets a global mapping to Neovim, which allows you to toggle the scratchPad feature.
        -- When `false`, the mapping is not created.
        ---@type string
        scratchPad = "<Leader>ns",
    },
    --- Allows you to provide custom code to run before (pre) and after (post) no-neck-pain steps (e.g. enabling).
    --- See |NoNeckPain.callbacks|
    ---@type table
    callbacks = {
        -- Runs right before centering the buffer
        ---@type fun(state: { enabled: boolean, active_tab: number, tabs: number--[[[] --]], disabled_tabs: number[], previously_focused_win: number })|nil
        preEnable = nil,
        -- Runs right after the buffer is centered
        ---@type fun(state: { enabled: boolean, active_tab: number, tabs: number[], disabled_tabs: number[], previously_focused_win: number })|nil
        postEnable = nil,
        -- Runs right before toggling NoNeckPain off
        ---@type fun(state: { enabled: boolean, active_tab: number, tabs: number[], disabled_tabs: number[], previously_focused_win: number })|nil
        preDisable = nil,
        -- Runs right after NoNeckPain has been turned off
        ---@type fun(state: { enabled: boolean, active_tab: number, tabs: number[], disabled_tabs: number[], previously_focused_win: number })|nil
        postDisable = nil,
    },
    --- Common options that are set to both side buffers.
    --- See |NoNeckPain.bufferOptions| for option scoped to the `left` and/or `right` buffer.
    ---@type table
    buffers = {
        -- When `true`, the side buffers will be named `no-neck-pain-left` and `no-neck-pain-right` respectively.
        ---@type boolean
        setNames = false,
        -- Leverages the side buffers as notepads, which work like any Neovim buffer and automatically saves its content at the given `location`.
        -- note: quitting an unsaved scratchPad buffer is non-blocking, and the content is still saved.
        --- see |NoNeckPain.bufferOptionsScratchPad|
        scratchPad = NoNeckPain.bufferOptionsScratchPad,
        -- colors to apply to both side buffers, for buffer scopped options @see |NoNeckPain.bufferOptions|
        --- see |NoNeckPain.bufferOptionsColors|
        colors = NoNeckPain.bufferOptionsColors,
        -- Vim buffer-scoped options: any `vim.bo` options is accepted here.
        ---@see NoNeckPain.bufferOptionsBo `:h NoNeckPain.bufferOptionsBo`
        bo = NoNeckPain.bufferOptionsBo,
        -- Vim window-scoped options: any `vim.wo` options is accepted here.
        ---@see NoNeckPain.bufferOptionsWo `:h NoNeckPain.bufferOptionsWo`
        wo = NoNeckPain.bufferOptionsWo,
        --- Options applied to the `left` buffer, options defined here overrides the `buffers` ones.
        ---@see NoNeckPain.bufferOptions `:h NoNeckPain.bufferOptions`
        left = NoNeckPain.bufferOptions,
        --- Options applied to the `right` buffer, options defined here overrides the `buffers` ones.
        ---@see NoNeckPain.bufferOptions `:h NoNeckPain.bufferOptions`
        right = NoNeckPain.bufferOptions,
    },
    -- Supported integrations that might clash with `no-neck-pain.nvim`'s behavior.
    --
    -- The `position` is used when the plugin scans the layout in order to compute the width that should be added
    -- on each side. For example, if you were supposed to have a padding of 100 columns on each side, but an
    -- integration takes 42, only 58 will be added so your layout is still centered.
    --
    -- If `reopen` is set to `false`, we won't account the width but close the integration when encountered.
    ---@type table
    integrations = {
        -- @link https://github.com/nvim-tree/nvim-tree.lua
        ---@type table
        NvimTree = {
            -- The position of the tree.
            ---@type "left"|"right"
            position = "left",
            -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
            ---@type boolean
            reopen = true,
        },
        -- @link https://github.com/nvim-neo-tree/neo-tree.nvim
        NeoTree = {
            -- The position of the tree.
            ---@type "left"|"right"
            position = "left",
            -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
            reopen = true,
        },
        -- @link https://github.com/mbbill/undotree
        undotree = {
            -- The position of the tree.
            ---@type "left"|"right"
            position = "left",
        },
        -- @link https://github.com/nvim-neotest/neotest
        neotest = {
            -- The position of the tree.
            ---@type "right"
            position = "right",
            -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
            reopen = true,
        },
        -- @link https://github.com/rcarriga/nvim-dap-ui
        NvimDAPUI = {
            -- The position of the tree.
            ---@type "none"
            position = "none",
            -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
            reopen = true,
        },
        -- @link https://github.com/hedyhli/outline.nvim
        outline = {
            -- The position of the tree.
            ---@type "left"|"right"
            position = "right",
            -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
            reopen = true,
        },
        -- @link https://github.com/stevearc/aerial.nvim
        aerial = {
            -- The position of the tree.
            ---@type "left"|"right"
            position = "right",
            -- When `true`, if the tree was opened before enabling the plugin, we will reopen it.
            reopen = true,
        },
        -- this is a generic field to hint no-neck-pain that you use a dashboard plugin.
        -- you can find the filetype list of natively supported dashboards here: https://github.com/shortcuts/no-neck-pain.nvim/blob/main/lua/no-neck-pain/util/constants.lua#L82-L85
        -- if a dashboard that you use isn't supported, either set `dashboard.filetype` to the expected file type, or open a pull-request with the edited list.
        dashboard = {
            -- When `true`, debounce will be applied to the init method, leaving time for the dashboard to open.
            enabled = false,
            -- if a dashboard that you use isn't supported, you can use this field to set a matching filetype, also don't hesitate to open a pull-request with the edited list (DASHBOARDS) found in lua/no-neck-pain/util/constants.lua.
            ---@type string[]|nil
            filetypes = nil,
        },
    },
})

--- NoNeckPain's buffer `vim.wo` options.
---@see window options `:h vim.wo`
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
NoNeckPain.bufferOptionsWo = {
    ---@type boolean
    cursorline = false,
    ---@type boolean
    cursorcolumn = false,
    ---@type string
    colorcolumn = "0",
    ---@type boolean
    number = false,
    ---@type boolean
    relativenumber = false,
    ---@type boolean
    foldenable = false,
    ---@type boolean
    list = false,
    ---@type boolean
    wrap = true,
    ---@type boolean
    linebreak = true,
}

--- NoNeckPain's buffer `vim.bo` options.
---@see buffer options `:h vim.bo`
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
NoNeckPain.bufferOptionsBo = {
    ---@type string
    filetype = "no-neck-pain",
    ---@type string
    buftype = "nofile",
    ---@type string
    bufhidden = "hide",
    ---@type boolean
    buflisted = false,
    ---@type boolean
    swapfile = false,
}

--- NoNeckPain's scratchPad buffer options.
---
--- Leverages the side buffers as notepads, which work like any Neovim buffer and automatically saves its content at the given `location`.
--- note: quitting an unsaved scratchPad buffer is non-blocking, and the content is still saved.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
NoNeckPain.bufferOptionsScratchPad = {
    -- When `true`, automatically sets the following options to the side buffers:
    -- - `autowriteall`
    -- - `autoread`.
    ---@type boolean
    enabled = false,
    -- The name of the generated file. See `location` for more information.
    -- /!\ deprecated /!\ use `pathToFile` instead.
    ---@type string
    ---@example: `no-neck-pain-left.norg`
    ---@deprecated: use `pathToFile` instead.
    fileName = "no-neck-pain",
    -- By default, files are saved at the same location as the current Neovim session.
    -- note: filetype is defaulted to `norg` (https://github.com/nvim-neorg/neorg), but can be changed in `buffers.bo.filetype` or |NoNeckPain.bufferOptions| for option scoped to the `left` and/or `right` buffer.
    -- /!\ deprecated /!\ use `pathToFile` instead.
    ---@type string?
    ---@example: `no-neck-pain-left.norg`
    ---@deprecated: use `pathToFile` instead.
    location = nil,
    -- The path to the file to save the scratchPad content to and load it in the buffer.
    ---@type string?
    ---@example: `~/notes.norg`
    pathToFile = "",
}

--- NoNeckPain's buffer color options.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
NoNeckPain.bufferOptionsColors = {
    -- Hexadecimal color code to override the current background color of the buffer. (e.g. #24273A)
    -- Transparent backgrounds are supported by default.
    ---@type string?
    background = nil,
    -- Brighten (positive) or darken (negative) the side buffers background color. Accepted values are [-1..1].
    ---@type integer
    blend = 0,
    -- Hexadecimal color code to override the current text color of the buffer. (e.g. #7480c2)
    ---@type string?
    text = nil,
}

--- NoNeckPain's buffer side buffer option.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
NoNeckPain.bufferOptions = {
    -- When `false`, the buffer won't be created.
    ---@type boolean
    enabled = true,
    ---@see NoNeckPain.bufferOptionsColors `:h NoNeckPain.bufferOptionsColors`
    colors = NoNeckPain.bufferOptionsColors,
    ---@see NoNeckPain.bufferOptionsBo `:h NoNeckPain.bufferOptionsBo`
    bo = NoNeckPain.bufferOptionsBo,
    ---@see NoNeckPain.bufferOptionsWo `:h NoNeckPain.bufferOptionsWo`
    wo = NoNeckPain.bufferOptionsWo,
    ---@see NoNeckPain.bufferOptionsScratchPad `:h NoNeckPain.bufferOptionsScratchPad`
    scratchPad = NoNeckPain.bufferOptionsScratchPad,
}
