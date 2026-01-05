return {
  {
    'jackMort/ChatGPT.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim' },
    cmd = { 'ChatGPT', 'ChatGPTRun' },
    keys = {
      { '<leader>ac', ':ChatGPT<cr>', desc = 'ChatGPT: Open' },
    },
    config = function()
      require('chatgpt').setup({})
    end,
  },
  {
    'piersolenski/wtf.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-telescope/telescope.nvim',
      'folke/snacks.nvim',
      'ibhagwan/fzf-lua',
    },
    opts = {},
    keys = {
      {
        '<leader>wwd',
        mode = { 'n', 'x' },
        function()
          require('wtf').diagnose()
        end,
        desc = 'Debug diagnostic with AI',
      },
      {
        '<leader>wwf',
        mode = { 'n', 'x' },
        function()
          require('wtf').fix()
        end,
        desc = 'Fix diagnostic with AI',
      },
      {
        mode = { 'n' },
        '<leader>wws',
        function()
          require('wtf').search()
        end,
        desc = 'Search diagnostic with Google',
      },
      {
        mode = { 'n' },
        '<leader>wwp',
        function()
          require('wtf').pick_provider()
        end,
        desc = 'Pick provider',
      },
      {
        mode = { 'n' },
        '<leader>wwh',
        function()
          require('wtf').history()
        end,
        desc = 'Populate the quickfix list with previous chat history',
      },
      {
        mode = { 'n' },
        '<leader>wwg',
        function()
          require('wtf').grep_history()
        end,
        desc = 'Grep previous chat history with Telescope',
      },
    },
  },
}
