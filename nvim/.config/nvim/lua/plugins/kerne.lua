-- Kerne language support from the local checkout in ~/dev/kerne:
-- regex syntax highlighting for *.krn files and diagnostics on save via the kerne CLI.
-- Build the CLI once with `cargo build --release -p kerne_cli` in ~/dev/kerne/compiler.
return {
  {
    dir = vim.fn.expand("~/dev/kerne/editor/vim"),
    name = "kerne-vim",
    lazy = false,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.kerne = { "kerne" }
      opts.linters.kerne = {
        cmd = vim.fn.expand("~/dev/kerne/compiler/target/release/kerne"),
        args = { "resolve", "--short" },
        stdin = false,
        stream = "stderr",
        ignore_exitcode = true,
        parser = require("lint.parser").from_errorformat("%f:%l:%c: %t%*[^:]: %m", { source = "kerne" }),
      }
    end,
  },
}
