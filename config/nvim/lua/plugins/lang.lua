-- Language support for Java, Kotlin, Starlark, Markdown, and plaintext.
-- LazyVim extras (java, kotlin, markdown) are imported in lazy.lua in the correct order.

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

  -- Starlark treesitter parser (no LazyVim extra exists for it)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "starlark" },
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
      },
    },
  },
}
