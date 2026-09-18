-- <space>gB toggle for :Gitsigns blame.
--
-- gitsigns draws separator lines into the file buffer and turns on scrollbind
-- in its window while the blame column is open, and only undoes both from an
-- autocmd on the blame window closing. Closing things in any other order
-- leaves the file with stray separators and a window that scrolls in step
-- with its neighbours, so always close the blame window itself.

local M = {}

function M.toggle()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'gitsigns-blame' then
            vim.api.nvim_win_close(win, true)
            return
        end
    end
    require('gitsigns').blame()
end

return M
