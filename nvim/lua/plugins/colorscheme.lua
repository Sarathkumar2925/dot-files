-- return {
--     "catppuccin/nvim",
--     name = "catppuccin",
--     lazy = false,
--     priority = 1000,
--     config = function()
--         -- Set the Catppuccin Mocha flavor
--         require("catppuccin").setup({
--             flavour = "mocha", -- latte, frappe, macchiato, mocha
--         })
--
--         -- Apply the color scheme
--         vim.cmd.colorscheme "catppuccin"
--     end,
-- }

return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
      style = "night"
  },
  config = function (_, opts)
      require("tokyonight").setup(opts)
    vim.cmd.colorscheme "tokyonight"
  end
}
