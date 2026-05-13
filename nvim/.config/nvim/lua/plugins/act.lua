return {
  {
    "czepluch/tree-sitter-act",
    dir = "/home/jstcz/dev/argot/tree-sitter-act",
    build = "mkdir -p ~/.local/share/nvim/site/parser && cc -O2 -shared -fPIC -I src src/parser.c -o ~/.local/share/nvim/site/parser/act.so",
    ft = "act",
  },
}
