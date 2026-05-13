return {
  {
    "czepluch/tree-sitter-core-solidity",
    dir = "/home/jstcz/dev/argot/tree-sitter-core-solidity",
    build = "mkdir -p ~/.local/share/nvim/site/parser && cc -O2 -shared -fPIC -I src src/parser.c src/scanner.c -o ~/.local/share/nvim/site/parser/core_solidity.so",
    ft = "core_solidity",
    dependencies = {
      {
        "czepluch/tree-sitter-yul",
        dir = "/home/jstcz/dev/argot/tree-sitter-yul",
        build = "mkdir -p ~/.local/share/nvim/site/parser && cc -O2 -shared -fPIC -I src src/parser.c -o ~/.local/share/nvim/site/parser/yul.so",
      },
    },
  },
}
