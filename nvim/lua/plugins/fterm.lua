return {
  {
    'numToStr/FTerm.nvim',
    config = function()
      local FTerm = require('FTerm')

      -- Default terminal instance
      vim.keymap.set('n', '<leader>tt', function()
        FTerm.toggle() -- Use the default toggle method provided by FTerm
      end, { desc = '[T]oggle [T]erminal' })
      vim.keymap.set('t', '<leader>tt', function()
        FTerm.toggle() -- Use the default toggle method provided by FTerm
      end, { desc = '[T]oggle [T]erminal' })

      -- LazyGit terminal instance
      local lazygit = FTerm:new({
        cmd = 'lazygit',
        dimensions = {
          height = 0.9, -- 90% of the screen height
          width = 0.9,  -- 90% of the screen width
        },
      })

      vim.keymap.set('n', '<leader>lg', function()
        lazygit:toggle()
      end, { desc = 'Toggle [L]azy[G]it' })
      vim.keymap.set('t', '<leader>lg', function()
        lazygit:toggle()
      end, { desc = 'Toggle [L]azy[G]it' })
    end,
  },
}
