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
