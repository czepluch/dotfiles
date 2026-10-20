return {
  {
    dir = vim.fn.expand("~/dev/lean/kort/tree-sitter-kort"),
    build = "mkdir -p ~/.local/share/nvim/site/parser && cc -O2 -shared -fPIC -I src src/parser.c src/scanner.c -o ~/.local/share/nvim/site/parser/kort.so",
    ft = "kort",
  },
}
