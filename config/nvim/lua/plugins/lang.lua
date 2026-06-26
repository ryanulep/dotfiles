-- Language support beyond what LazyVim extras cover.
-- Extras (go, java, kotlin, typescript, markdown, yaml, json, git) are imported in lazy.lua.

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "google-java-format",
        "ktfmt",
        "buildifier",
        "mdformat",
        "kotlin-lsp",
        "starpls",
        "buf",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Use JetBrains kotlin_lsp instead of the community kotlin_language_server.
        -- The Mason `kotlin-lsp` package symlinks its binary as `intellij-server`
        -- (not `kotlin-lsp`), so nvim-lspconfig's default cmd would fail to launch.
        kotlin_language_server = { enabled = false },
        kotlin_lsp = {
          cmd = { vim.fn.stdpath("data") .. "/mason/bin/intellij-server", "--stdio" },
        },
        starpls = {},
        buf_ls = {},
      },
      -- Configured here rather than options.lua so it runs after LazyVim's own
      -- diagnostic setup and isn't overwritten
      diagnostics = {
        virtual_text = false,
        signs = true,
        underline = true,
        update_in_insert = false,
      },
    },
  },

  -- Treesitter parsers not covered by any LazyVim extra
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "starlark", "proto", "python", "cpp" },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        java = { "google-java-format" },
        kotlin = { "ktfmt" },  -- overrides ktlint set by the kotlin extra
        bzl = { "buildifier" },
        markdown = { "mdformat" },
        proto = { "buf" },
      },
    },
  },
}
