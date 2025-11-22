return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Solidity language server
        solidity_ls_nomicfoundation = {},
        -- Gleam language server
        gleam = {},
      },
    },
  },
}
