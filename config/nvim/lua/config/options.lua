-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.opt.scrolloff = 2
vim.opt.shell = "zsh"
vim.opt.statuscolumn = "%4{v:lnum}  %2{v:relnum} "

-- Switch Python LSP to basedpyright (community fork, current LazyVim recommendation)
vim.g.lazyvim_python_lsp = "basedpyright"
