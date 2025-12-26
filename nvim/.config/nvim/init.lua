-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load Aether theme (must be after lazy.nvim setup)
dofile(vim.fn.expand("~/.config/aether/theme/neovim.lua"))
