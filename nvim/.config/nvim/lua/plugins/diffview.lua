-- Diffview: review every changed file in one tab with side-by-side diffs.
-- Fork of sindrets/diffview.nvim, which stopped receiving updates in 2024.
local function toggle_diffview()
  if require("diffview.lib").get_current_view() then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end

return {
  "dlyongemallo/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gv", toggle_diffview, desc = "Diffview (working tree vs HEAD)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview repo history" },
  },
  opts = {},
}
