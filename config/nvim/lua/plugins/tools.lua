-- External tool integrations

return {
  -- Navigate seamlessly between Neovim splits and tmux panes with <C-h/j/k/l>.
  -- Works whether or not you're inside tmux — falls back to normal split navigation.
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate left" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate down" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate up" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
    },
  },
}
