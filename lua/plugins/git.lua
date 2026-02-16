return {
  { 'sindrets/diffview.nvim', 
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggle', 'DiffviewFileHistory' }
  },

  -- Neogit disabled - too slow on Windows (~3s to open)
  -- {
  --   "NeogitOrg/neogit",
  --   lazy = true,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "sindrets/diffview.nvim",
  --     "nvim-telescope/telescope.nvim",
  --     "folke/snacks.nvim",
  --   },
  --   cmd = "Neogit",
  --   keys = {
  --     { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit UI" }
  --   }
  -- },
}
