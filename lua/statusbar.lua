-- Nearest enclosing function or method, shown in the lightline statusbar.
--
-- This replaces vista.vim. The symbols come straight from the language server
-- via textDocument/documentSymbol and are cached per buffer, so moving the
-- cursor only searches the cache rather than talking to the server.

local M = {}

-- Symbol kinds worth naming in the statusbar
local kinds = {
    [vim.lsp.protocol.SymbolKind.Function] = true,
    [vim.lsp.protocol.SymbolKind.Method] = true,
    [vim.lsp.protocol.SymbolKind.Constructor] = true,
}

-- bufnr -> flat list of {name, kind, srow, erow}, rows are 0 based
local cache = {}

-- A documentSymbol reply is either a DocumentSymbol[] tree (clangd) or a flat
-- SymbolInformation[] list, which puts the range one level down, so handle both
local function collect(items, out)
    for _, item in ipairs(items) do
        local range = item.range or (item.location and item.location.range)
        if range then
            out[#out + 1] = {
                name = item.name,
                kind = item.kind,
                srow = range.start.line,
                erow = range['end'].line,
            }
        end
        if item.children then
            collect(item.children, out)
        end
    end
end

local function refresh(bufnr)
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
    vim.lsp.buf_request_all(bufnr, 'textDocument/documentSymbol', params, function(results)
        local symbols = {}
        for _, response in pairs(results) do
            if response.result then
                collect(response.result, symbols)
            end
        end
        vim.schedule(function()
            if vim.api.nvim_buf_is_loaded(bufnr) then
                cache[bufnr] = symbols
                vim.cmd('redrawstatus')
            end
        end)
    end)
end

-- Called by lightline on every statusline redraw, so it has to stay cheap: it
-- only scans the cached symbols for the innermost one containing the cursor
function M.nearest()
    local symbols = cache[vim.api.nvim_get_current_buf()]
    if not symbols then
        return ''
    end

    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local best
    for _, symbol in ipairs(symbols) do
        if kinds[symbol.kind] and symbol.srow <= row and row <= symbol.erow then
            if not best or symbol.erow - symbol.srow < best.erow - best.srow then
                best = symbol
            end
        end
    end

    return best and best.name or ''
end

local group = vim.api.nvim_create_augroup('NearestMethodOrFunction', {})

-- LspAttach is the first point at which the server can answer, BufWritePost
-- picks up symbols added or removed since
vim.api.nvim_create_autocmd({ 'LspAttach', 'BufWritePost' }, {
    group = group,
    callback = function(ev)
        refresh(ev.buf)
    end,
})

vim.api.nvim_create_autocmd({ 'LspDetach', 'BufDelete' }, {
    group = group,
    callback = function(ev)
        cache[ev.buf] = nil
    end,
})

-- lightline's component_function takes the name of a Vim function
vim.cmd([[
function! NearestMethodOrFunction() abort
  return v:lua.require'statusbar'.nearest()
endfunction
]])

vim.g.lightline = {
    colorscheme = '16color',
    active = {
        left = {
            { 'mode', 'paste' },
            { 'readonly', 'absolutepath', 'modified', 'method' },
        },
    },
    component_function = {
        method = 'NearestMethodOrFunction'
    },
}

return M
