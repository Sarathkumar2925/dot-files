local opts = { noremap = true, silent = true }

-- Disable arrow keys in normal mode
vim.api.nvim_set_keymap('n', '<Up>', '<Nop>', opts)
vim.api.nvim_set_keymap('n', '<Down>', '<Nop>', opts)
vim.api.nvim_set_keymap('n', '<Left>', '<Nop>', opts)
vim.api.nvim_set_keymap('n', '<Right>', '<Nop>', opts)

-- Disable arrow keys in insert mode
-- vim.api.nvim_set_keymap('i', '<Up>', '<Nop>', opts)
-- vim.api.nvim_set_keymap('i', '<Down>', '<Nop>', opts)
-- vim.api.nvim_set_keymap('i', '<Left>', '<Nop>', opts)
-- vim.api.nvim_set_keymap('i', '<Right>', '<Nop>', opts)

-- Disable arrow keys in visual mode
vim.api.nvim_set_keymap('v', '<Up>', '<Nop>', opts)
vim.api.nvim_set_keymap('v', '<Down>', '<Nop>', opts)
vim.api.nvim_set_keymap('v', '<Left>', '<Nop>', opts)
vim.api.nvim_set_keymap('v', '<Right>', '<Nop>', opts)
