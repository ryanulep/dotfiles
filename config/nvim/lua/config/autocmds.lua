-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

vim.filetype.add({
  filename = {
    ["BUILD"] = "bzl",
    ["BUILD.bazel"] = "bzl",
    ["WORKSPACE"] = "bzl",
    ["WORKSPACE.bazel"] = "bzl",
  },
  extension = {
    bzl = "bzl",
    star = "bzl",
  },
})

-- Spell check and soft word wrap for prose filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("prose_settings", { clear = true }),
  pattern = { "text", "markdown", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})
