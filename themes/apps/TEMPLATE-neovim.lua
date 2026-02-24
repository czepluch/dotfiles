-- Template for adding a neovim colorscheme to a palette.
--
-- How to use:
--   1. Copy this file to apps/<palette>/neovim.lua
--   2. Fill in the plugin details below
--   3. Run: theme-set --neovim <palette>
--
-- Finding the right plugin:
--   - Search GitHub for "<theme> neovim" (e.g. "ayu neovim")
--   - Browse https://github.com/rockerBOO/awesome-neovim#colorscheme
--   - Browse https://dotfyle.com/neovim/colorscheme
--   Most popular themes have a plugin named "author/<theme>.nvim".
--
-- Finding the right values:
--   Check the plugin's README for setup() and colorscheme examples.
--   The three values you need:
--     repo    - GitHub "owner/repo" (shown at top of the repo page)
--     module  - Lua module name passed to require() (usually in README)
--     scheme  - String passed to vim.cmd.colorscheme() (usually in README)
--
-- Example (tokyonight):
--   return {
--     {
--       "folke/tokyonight.nvim",
--       lazy = false,
--       priority = 1000,
--       opts = {
--         style = "night",
--       },
--       config = function(_, opts)
--         require("tokyonight").setup(opts)
--         vim.cmd.colorscheme("tokyonight")
--       end,
--     },
--   }

return {
  {
    "OWNER/REPO",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("MODULE").setup(opts)
      vim.cmd.colorscheme("SCHEME")
    end,
  },
}
