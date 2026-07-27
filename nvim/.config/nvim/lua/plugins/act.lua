return {
  {
    "czepluch/tree-sitter-act",
    dir = vim.fn.expand("~/dev/argot/tree-sitter-act"),
    build = "mkdir -p ~/.local/share/nvim/site/parser && cc -O2 -shared -fPIC -I src src/parser.c -o ~/.local/share/nvim/site/parser/act.so",
    ft = "act",
  },
}
