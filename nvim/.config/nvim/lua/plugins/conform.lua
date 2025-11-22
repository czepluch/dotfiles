return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        gleam = { "gleam" },
        solidity = { "forge_fmt" },
      },
      formatters = {
        gleam = {
          command = "gleam",
          args = { "format", "--stdin" },
          stdin = true,
        },
        forge_fmt = {
          command = "forge",
          args = { "fmt", "--raw", "-" },
          stdin = true,
        },
      },
    },
  },
}
