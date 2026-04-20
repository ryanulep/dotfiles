-- Language support for Java, Kotlin, Python, Starlark, Markdown, and plaintext.
-- LazyVim extras (java, python, markdown) are imported in lazy.lua in the correct order.

return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "google-java-format",
        "ktfmt",
        "buildifier",
        "mdformat",
        "debugpy",
        "kotlin-lsp",
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Use JetBrains kotlin_lsp instead of the community kotlin_language_server
        kotlin_language_server = { enabled = false },
        kotlin_lsp = {},
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

  -- Python debugger; debugpy itself is installed via Mason above
  {
    "mfussenegger/nvim-dap-python",
    dependencies = "mfussenegger/nvim-dap",
    ft = "python",
    config = function()
      local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(debugpy)
    end,
  },

  -- Python test runner via pytest (<leader>tt / <leader>tr)
  -- Java uses the jdtls built-in runner with the same keymaps (buffer-local, takes precedence)
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-python" },
    opts = {
      adapters = {
        ["neotest-python"] = {
          dap = { justMyCode = false },
          runner = "pytest",
        },
      },
    },
  },
}
