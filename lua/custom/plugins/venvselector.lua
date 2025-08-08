return {
  {
    'linux-cultist/venv-selector.nvim',
    -- lazy = true,
    branch = 'regexp',
    dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim', 'mfussenegger/nvim-dap-python' },
    config = function()
      require('venv-selector').setup {}
      -- Keymap to open VenvSelector to pick a venv.
      vim.keymap.set('n', '<leader>vs', '<cmd>VenvSelect<cr>', { desc = 'Select Venv' })
      -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
      vim.keymap.set('n', '<leader>vc', '<cmd>VenvSelectCached<cr>', { desc = 'Select Cached Venv' })
    end,
  },
}
