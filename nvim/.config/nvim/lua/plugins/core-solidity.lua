return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      vim.filetype.add({
        extension = { solc = "core_solidity" },
      })
    end,
  },
}
