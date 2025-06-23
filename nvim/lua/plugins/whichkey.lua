return {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
        -- gain access to the which key plugin
        local which_key = require('which-key')

        -- call the setup function with default properties
        which_key.setup()

        -- Register prefixes for the different key mappings we have setup previously
        which_key.register({
            ['<leader>/'] = {name = "Comments", _ = 'which_key_ignore'},
            ['<leader>c'] = {
                name = '[C]ode',
                a = {":lua vim.lsp.buf.code_action()<CR>", "[A]ctions"},
                f = {":lua vim.lsp.buf.formatting()<CR>", "[F]ormat"},
            },
            ['<leader>d'] = {name = '[D]ebug' , _ = 'which_key_ignore'},
            ['<leader>e'] = {name = '[E]xplorer', _ = 'which_key_ignore'},
            ['<leader>f'] = { name = '[F]ind', _ = 'which_key_ignore' },
            ['<leader>g'] = {
                name = '[G]it',
                s = {":Git status<CR>", "[S]tatus"},
                l = {":Git log<CR>", "[L]og"}
            },
            ['<leader>J'] = { name = '[J]ava', _ = 'which_key_ignore' },
            ['<leader>w'] = {name = '[W]indow', _ = 'which_key_ignore'}
        })
    end
}
