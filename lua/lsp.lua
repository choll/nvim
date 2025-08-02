-- Capabilities config required by nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local lspconfig = require('lspconfig')

lspconfig.clangd.setup {
    cmd = {'clangd', '--background-index', '--clang-tidy', '--header-insertion=iwyu'},
    filetypes = {'c', 'h', 'cpp', 'hpp'},
    on_attach = function(client, bufnr)
        -- Disable LSP based syntax highlighting
        client.server_capabilities.semanticTokensProvider = nil
    end
}

lspconfig.pylsp.setup({
    settings = {
        pylsp = {
            plugins = {
                pyflakes = { enabled = true },
                rope_autoimport = { enabled = true },
                rope_completion = { enabled = true },
                black = { enabled = true },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
            }
        }
    }
})

require('lsp-endhints').setup {
	icons = {
		type = '=> ',
		parameter = '<- ',
		offspec = 'nospec: ', -- hint kind not defined in official LSP spec
		unknown = 'unknown: ', -- hint kind is nil
	},
	label = {
		truncateAtChars = 20,
		padding = 1,
		marginLeft = 0,
		sameKindSeparator = ', ',
	},
	extmark = {
		priority = 50,
	},
	autoEnableHints = true,
}

vim.diagnostic.config({
    virtual_text = {
        prefix = "*"
    }
})

-- See https://github.com/neovim/nvim-lspconfig/blob/01b25ff1a66745d29ff75952e9f605e45611746e/README.md

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end,
})
