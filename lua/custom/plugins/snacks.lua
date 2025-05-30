return {
  {
    'folke/snacks.nvim',
    ---@type snacks.Config
    opts = {
      lazygit = {
        enabled = true,
      },
      scratch = {
        enabled = true,
      },
    },
    keys = {
      {
        '<leader>wg',
        function()
          Snacks.lazygit.open()
        end,
        desc = 'Open LazyGit',
      },
      {
        '<leader>.',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>S',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
    },
  },
}
