-- Kerne language support from the local checkout in ~/dev/kerne:
-- regex syntax highlighting for *.krn files and diagnostics on save via the kerne CLI.
-- The CLI runs through `cargo run`, so it rebuilds itself whenever the compiler changed;
-- the first save after a change waits for the build, later saves are instant.
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
        cmd = "cargo",
        args = {
          "run",
          "-q",
          "--release",
          "--manifest-path",
          vim.fn.expand("~/dev/kerne/compiler/Cargo.toml"),
          "-p",
          "kerne_cli",
          "--",
          "check",
          "--short",
        },
        stdin = false,
        stream = "stderr",
        ignore_exitcode = true,
        parser = require("lint.parser").from_errorformat("%f:%l:%c: %t%*[^:]: %m", { source = "kerne" }),
      }
    end,
  },
}
