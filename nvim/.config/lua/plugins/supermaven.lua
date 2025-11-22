return {
  -- Supermaven - Fast AI code completion
  {
    "supermaven-inc/supermaven-nvim",
    event = "VeryLazy",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        ignore_filetypes = { cpp = true }, -- disable for specific filetypes
        color = {
          suggestion_color = "#808080", -- gray color for suggestions
          cterm = 244,
        },
        log_level = "info", -- set to "off" to disable logging
        disable_inline_completion = false, -- keep inline completions enabled
        disable_keymaps = false,
      })
    end,
  },
}
