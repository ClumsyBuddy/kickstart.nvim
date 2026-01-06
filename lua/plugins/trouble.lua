return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle", "TroubleRefresh" },
    keys = {
      { "<leader>tt", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Toggle Trouble (document diagnostics)" },
    },
    config = function()
      require("trouble").setup({
        position = "bottom",
        height = 10,
        icons = true,
        fold_open = "v",
        fold_closed = "o",
        use_diagnostic_signs = true,
      })
    end,
  },
}
