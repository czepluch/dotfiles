-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set default indentation to 4 spaces (override LazyVim's 2-space default)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Diff mode turns wrap off by itself; keep each buffer's own wrap setting so
-- one-sentence-per-line prose stays readable in vimdiff.
vim.opt.diffopt:append("followwrap")
