-- Theme-system bridge: theme-set copies the active palette's neovim spec to
-- ~/.config/themes/current/nvim-colorscheme.lua and this stub dofile's it on
-- every nvim start. Keeps palette switches out of git (this file never
-- changes). The fallback spec applies on a fresh clone before the first
-- theme-set run.
local ok, spec = pcall(dofile, vim.fn.expand("~/.config/themes/current/nvim-colorscheme.lua"))
if ok and type(spec) == "table" then
  return spec
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
