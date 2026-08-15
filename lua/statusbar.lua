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

local update, scanned

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
            if not vim.api.nvim_buf_is_loaded(bufnr) then
                return
            end
            cache[bufnr] = symbols
            scanned[bufnr] = nil
            -- Nothing has moved the cursor since, so ask for the redraw here
            if bufnr == vim.api.nvim_get_current_buf() and update() then
                vim.cmd('redrawstatus')
            end
        end)
    end)
end

-- Innermost symbol containing the row. Nested symbols mean the innermost is
-- simply the smallest range that still contains it.
local function nearest(bufnr, row)
    local symbols = cache[bufnr]
    if not symbols then
        return ''
    end

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

-- Row the cached name was scanned for, per buffer
scanned = {}

-- The scan runs at most once per line the cursor lands on and the result is
-- parked in a buffer variable, so the statusline component stays a plain
-- variable read. The statusline is redrawn far more often than the cursor
-- changes line -- CursorMovedI alone fires on every keystroke -- and rescanning
-- from the component cost ~9.5us per redraw against ~1.4us for the variable
-- read, measured on a 12k line file with ~2500 symbols.
function update()
    local bufnr = vim.api.nvim_get_current_buf()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    if scanned[bufnr] == row then
        return false
    end
    scanned[bufnr] = row

    local name = nearest(bufnr, row)
    if vim.b[bufnr].nearest_method_or_function ~= name then
        vim.b[bufnr].nearest_method_or_function = name
        return true
    end
    return false
end

local group = vim.api.nvim_create_augroup('NearestMethodOrFunction', {})

-- Runs before the redraw that the cursor move itself triggers, so the name
-- keeps up with the cursor without a debounce timer
vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufEnter' }, {
    group = group,
    -- Swallow the return value: a callback returning true deletes the autocmd
    callback = function()
        update()
    end,
})

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
        scanned[ev.buf] = nil
    end,
})

-- lightline's component_function takes the name of a Vim function. Keep it a
-- bare variable read: lightline calls it on every statusline redraw.
vim.cmd([[
function! NearestMethodOrFunction() abort
  return get(b:, 'nearest_method_or_function', '')
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
