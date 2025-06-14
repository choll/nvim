local cmp = require'cmp'

cmp.setup {
  completion = {
    autocomplete = false, -- no automatic triggering
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-n>'] = cmp.mapping.complete(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = 'nvim_lsp' },
  },
}
