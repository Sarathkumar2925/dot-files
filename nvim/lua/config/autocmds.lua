-- Setup our JDTLS server any time we open up a java file
vim.cmd [[
    augroup jdtls_lsp
        autocmd!
        autocmd FileType java lua require'config.jdtls'.setup_jdtls()
    augroup end
]]

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"java"},
  callback = function()
    vim.opt_local.textwidth = 120
  end
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function()
        vim.lsp.buf.format()
    end
})
