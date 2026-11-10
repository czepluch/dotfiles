return {
  {
    dir = vim.fn.expand("~/.local/opt/solcore/vim-solcore"),
    lazy = false,
    config = function()
      require("solcore").setup()
    end,
  },
}
