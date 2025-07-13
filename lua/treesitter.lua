require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "cpp", "markdown", "python" },
  highlight = {
    enable = true,
    -- Regex highlighting is enabled to highlight TODO, FIXME etc
    additional_vim_regex_highlighting = {"c", "cpp"},
  },
}
