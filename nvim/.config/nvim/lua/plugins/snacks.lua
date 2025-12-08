return {
  "folke/snacks.nvim",
  opts = {
    -- Enable components needed by opencode.nvim
    input = {},
    terminal = {},
    picker = {
      sources = {
        files = {
          hidden = true, -- Show hidden files in file picker
        },
        explorer = {
          hidden = true, -- Show hidden files in explorer by default
        },
      },
    },
  },
}
