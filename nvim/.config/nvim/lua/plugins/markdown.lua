-- markdownlint-cli2 lints stdin, so config discovery never leaves nvim's cwd
-- and ~/.markdownlint-cli2.yaml is ignored inside projects. --config supplies
-- it as a fallback; a config discovered in the cwd still takes precedence.
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml"), "-" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          prepend_args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml") },
        },
      },
    },
  },
}
