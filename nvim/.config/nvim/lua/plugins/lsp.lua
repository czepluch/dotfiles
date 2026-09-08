-- Directories where the Solidity language server must not attach.
-- solcore-rs is Core Solidity, which vscode-solidity-server cannot parse, and
-- indexing its test fixtures and fuzz corpora pins the server at full CPU.
local solidity_ls_disabled_dirs = {
  vim.fn.expand("~/dev/argot/solcore-rs"),
}

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Servers get one second to honour the shutdown request on exit before
      -- Neovim sends SIGTERM. The default (false) leaves unresponsive servers
      -- running as orphans after Neovim quits.
      ["*"] = { exit_timeout = 1000 },
      solidity_ls = {
        root_dir = function(bufnr, on_dir)
          local path = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
          for _, dir in ipairs(solidity_ls_disabled_dirs) do
            if vim.startswith(path, dir .. "/") then
              return
            end
          end
          on_dir(vim.fs.root(bufnr, vim.lsp.config.solidity_ls.root_markers))
        end,
      },
    },
  },
}
