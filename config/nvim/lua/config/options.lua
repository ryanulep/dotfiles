-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.opt.scrolloff = 2
vim.opt.shell = "zsh"
-- Keep the absolute/relative number layout, plus diagnostic/Git signs and folds.
-- Omitting %s hides errors even when diagnostics.signs is enabled.
vim.opt.statuscolumn = "%s%C%#LineNr#%4{v:lnum}%*  %#LineNrAbove#%2{v:relnum}%* "
