" Put the colour scheme first so that it doesn't break spelling or menu
" colours
colorscheme kanagawa

if has("termguicolors")
  set termguicolors
endif

" Copy the current visual selection to ~/.vbuf
vmap <C-y> :w! ~/.vbuf<CR>
" Copy the current line to the buffer file if no visual selection
nmap <C-y> :.w! ~/.vbuf<CR>
" Paste the contents of the buffer file
nmap <C-p> :r ~/.vbuf<CR>

" Previous tab
map <F1>   :tabp<CR>
" Next tab
map <F2>   :tabn<CR>
" Create tab
map <F3>   :tabnew<CR>
" Toggle between .cpp and corresponding .hpp file
map <F4>   :ClangdSwitchSourceHeader<CR>

" Map ctrl-n to LSP omnifunc (replace basic autocomplete with omnicompletion)
inoremap <C-n> <C-x><C-o>

set completeopt=menuone,noinsert
" Set popup menu background to dark grey and text to light grey
highlight Pmenu guibg=#3c3836 guifg=#d4be98 ctermbg=237 ctermfg=180
" Set selected item background to blue and text to white
highlight PmenuSel guibg=#458588 guifg=#ffffff ctermbg=66 ctermfg=15

" Turn on spell checking
set spell spelllang=en_gb
" Underline misspelt words
hi clear SpellBad
hi clear SpellCap
hi clear SpellRare
hi clear SpellLocal
hi SpellBad cterm=underline
hi SpellCap cterm=underline
hi SpellRare cterm=underline
hi SpellLocal cterm=underline

" When editing a file, always jump to the last known cursor position. 
" Don't do it when the position is invalid or when inside an event handler 
" (happens when dropping a file on gvim). 
autocmd BufReadPost * 
  \ if line("'\"") > 0 && line("'\"") <= line("$") | 
  \   exe "normal g`\"" | 
  \ endif 

" Use // comments for C++
autocmd FileType cpp setlocal commentstring=//\ %s

" Don't insert newline at EOF
set noeol

" Highlight trailing spaces
let c_space_errors = 1

set mouse=a
" Right click extends the selection instead of opening a menu
set mousemodel=extend

" Insert spaces on tab key
set expandtab

" Set tab width
set shiftwidth=4
set tabstop=4
set softtabstop=4

" Detect changes made to files by other programs
set autoread

" Visual selection does not include the cursor
set selection=exclusive

" Don't wrap long lines
set nowrap

" Show line numbers
set number

" Show LSP signs in place of line numbers instead of adding an extra column
set signcolumn=number

" nvim-lspconfig and clangd_extensions config
lua require('lsp')
lua require('autocomplete')
" Load lightline (statusbar) config
lua require('statusbar')
lua require('treesitter')
" Load gitsigns with the line number highlighted only. Replace
" signcolumn=number above with signcolumn=yes if the gitsigns signcolumn
" setting is enabled.
lua require('gitsigns').setup {numhl = true, signcolumn = false}
lua require('Comment')

" Vista is used to display the name of the function nearest to the cursor in
" the status bar
source ~/.config/nvim/vista.vim
