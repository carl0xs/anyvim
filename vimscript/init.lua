-- Nixvim's internal module table
-- Can be used to share code throughout init.lua
local _M = {}

-- Set up globals {{{
do
    local nixvim_globals = { mapleader = " " }

    for k, v in pairs(nixvim_globals) do
        vim.g[k] = v
    end
end
-- }}}

-- Set up options {{{
do
    local nixvim_options = {
        autoindent = true,
        clipboard = "unnamedplus",
        completeopt = "longest,menuone",
        encoding = "utf-8",
        fileencoding = "utf-8",
        foldlevelstart = 99,
        foldmethod = "expr",
        number = true,
        relativenumber = true,
        scrolloff = 8,
        sidescrolloff = 8,
        sw = 2,
        termguicolors = true,
        ts = 2,
        undofile = true,
    }

    for k, v in pairs(nixvim_options) do
        vim.opt[k] = v
    end
end
-- }}}

require("gruvbox").setup({})

vim.cmd([[colorscheme gruvbox
]])
require("nvim-web-devicons").setup({})

local cmp = require("cmp")
cmp.setup({
    mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-e>"] = cmp.mapping.close(),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<Tab>"] = cmp.mapping.select_next_item(),
    },
    sources = { { name = "nvim_lsp" }, { name = "path" }, { name = "buffer" } },
})

-- Create autogroup for treesitter autocmds
local augroup = vim.api.nvim_create_augroup("nixvim_treesitter", { clear = true })

-- Detect nvim-treesitter API
local has_configs_module = pcall(require, "nvim-treesitter.configs")

if has_configs_module then
    require("nvim-treesitter.configs").setup({})
else
    -- Enable features via autocommands for modern nvim-treesitter
    vim.api.nvim_create_autocmd("FileType", {
        group = augroup,
        pattern = "*",
        callback = function()
            pcall(vim.treesitter.start)
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
    })
end

require("lualine").setup({})

require("gitsigns").setup({})

require("fzf-lua").setup({
    fzf_opts = { ["--layout"] = "reverse-list" },
    winopts = { border = "none", col = 0.0, fullscreen = false, height = 0.4, row = 1.0, width = 1.0 },
})

require("diffview").setup({})

require("bufferline").setup({})

-- Set up keybinds {{{
do
    local __nixvim_binds = {
        { action = "<cmd>Vex<CR>", key = "<leader>e", mode = "" },
        { action = "<cmd>:w!<CR>", key = "<C-s>", mode = "" },
        { action = "<cmd>bprevious<CR>", key = "[b", mode = "" },
        { action = "<cmd>bnext<CR>", key = "]b", mode = "" },
        { action = "<cmd>bprev<CR>", key = "<S-h>", mode = "" },
        { action = "<cmd>bnext<CR>", key = "<S-l>", mode = "" },
        { action = "<cmd>bd<CR>", key = "<C-q>", mode = "" },
        { action = "<cmd>vsplit<CR>", key = "<leader>vs", mode = "" },
        { action = "<cmd>FzfLua files<CR>", key = "<leader>ff", mode = "" },
        { action = "<cmd>FzfLua grep_project<CR>", key = "<leader>fg", mode = "" },
        { action = "<cmd>FzfLua git_status<CR>", key = "<leader>gs", mode = "" },
        { action = "<cmd>Gitsigns toggle_current_line_blame<CR>", key = "<leader>gb", mode = "" },
        { action = "<cmd>Gitsigns next_hunk<CR>", key = "<leader>nh", mode = "" },
    }
    for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
    end
end
-- }}}

-- LSP {{{
do
    local __lspCapabilities = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()

        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        return capabilities
    end

    local __setup = { capabilities = __lspCapabilities() }

    local __wrapConfig = function(cfg)
        if cfg == nil then
            cfg = __setup
        else
            cfg = vim.tbl_extend("keep", cfg, __setup)
        end
        return cfg
    end

    vim.lsp.config("elixirls", __wrapConfig({}))
    vim.lsp.enable("elixirls")
    vim.lsp.config("eslint", __wrapConfig({}))
    vim.lsp.enable("eslint")
    vim.lsp.config("lua_ls", __wrapConfig({}))
    vim.lsp.enable("lua_ls")
    vim.lsp.config("nil_ls", __wrapConfig({}))
    vim.lsp.enable("nil_ls")
    vim.lsp.config("rust_analyzer", __wrapConfig({}))
    vim.lsp.enable("rust_analyzer")
    vim.lsp.config(
        "solargraph",
        __wrapConfig({
            cmd = { "solargraph" },
            filetypes = { "ruby", "eruby" },
            root_markers = { "Gemfile", "Rakefile" },
        })
    )
    vim.lsp.enable("solargraph")
    vim.lsp.config(
        "ts_ls",
        __wrapConfig({
            filetypes = {
                "javascript",
                "javascriptreact",
                "javascript.jsx",
                "typescript",
                "typescriptreact",
                "typescript.tsx",
            },
        })
    )
    vim.lsp.enable("ts_ls")
end
-- }}}

require("gitlineage").setup()
local lsp = vim.lsp

local signs = {
    Error = "✗",
    Warn = "⚠",
    Hint = "💡",
    Info = "ℹ",
}

lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

lsp.handlers["textDocument/signatureHelp"] = lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, server in pairs(vim.lsp.get_clients()) do
    server.server_capabilities = vim.tbl_deep_extend("force", server.server_capabilities, capabilities)
end

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.rb",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.ex",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.heex",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "ruby",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "elixir",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
    end,
})

vim.opt.iskeyword:remove("S")

-- Set up autogroups {{
do
    local __nixvim_autogroups = { nixvim_binds_LspAttach = { clear = true }, nixvim_lsp_on_attach = { clear = false } }

    for group_name, options in pairs(__nixvim_autogroups) do
        vim.api.nvim_create_augroup(group_name, options)
    end
end
-- }}
-- Set up autocommands {{
do
    local __nixvim_autocommands = {
        {
            callback = function()
                vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.wo[0][0].foldmethod = "expr"
            end,
            event = "FileType",
            group = "nixvim_treesitter",
            pattern = "*",
        },
        {
            callback = function(event)
                do
                    -- client and bufnr are supplied to the builtin `on_attach` callback,
                    -- so make them available in scope for our global `onAttach` impl
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    local bufnr = event.buf
                end
            end,
            desc = "Run LSP onAttach",
            event = "LspAttach",
            group = "nixvim_lsp_on_attach",
        },
        {
            callback = function(args)
                do
                    local __nixvim_binds = {}

                    for i, map in ipairs(__nixvim_binds) do
                        local options = vim.tbl_extend("keep", map.options or {}, { buffer = args.buf })
                        vim.keymap.set(map.mode, map.key, map.action, options)
                    end
                end
            end,
            desc = "Load keymaps for LspAttach",
            event = "LspAttach",
            group = "nixvim_binds_LspAttach",
        },
    }

    for _, autocmd in ipairs(__nixvim_autocommands) do
        vim.api.nvim_create_autocmd(autocmd.event, {
            group = autocmd.group,
            pattern = autocmd.pattern,
            buffer = autocmd.buffer,
            desc = autocmd.desc,
            callback = autocmd.callback,
            command = autocmd.command,
            once = autocmd.once,
            nested = autocmd.nested,
        })
    end
end
-- }}
