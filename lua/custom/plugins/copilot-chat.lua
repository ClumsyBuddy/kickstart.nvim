return {
  'CopilotC-Nvim/CopilotChat.nvim',
  dependencies = { { 'nvim-lua/plenary.nvim', branch = 'master' } },
  cmd = { 'CopilotChat', 'CopilotChatToggle', 'CopilotChatModels' },
  keys = {
    {
      '<leader>aa',
      function()
        require('CopilotChat').toggle()
      end,
      desc = 'CopilotChat: Toggle',
      mode = { 'n', 'v' },
    },
    {
      '<leader>ax',
      function()
        require('CopilotChat').reset()
      end,
      desc = 'CopilotChat: Clear',
      mode = { 'n', 'v' },
    },
    {
      '<leader>aq',
      function()
        local input = vim.fn.input 'Quick Chat: '
        if input ~= '' then
          require('CopilotChat').ask(input)
        end
      end,
      desc = 'CopilotChat: Quick Chat',
      mode = { 'n', 'v' },
    },
    { '<leader>ac', ':CopilotChatCommit<cr>', desc = 'CopilotChat: Commit', mode = { 'n', 'v' } },
  },
  config = function()
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = 'copilot-chat',
      callback = function()
        vim.opt_local.relativenumber = false
        vim.opt_local.number = false
      end,
    })

    require('CopilotChat').setup {
      -- Use Copilot provider; enable GitHub Models for Claude/Gemini/etc. (Copilot Pro)
      provider = 'copilot',
      providers = { github_models = { enabled = true } },

      -- Check available names with :CopilotChatModels (e.g., 'claude-3.5-sonnet', 'gpt-4.1', etc.)
      model = 'gpt-4.1',

      auto_insert_mode = true,

      window = {
        layout = 'float',
        relative = 'editor',
        row = 0,
        col = vim.o.columns - 80,
        width = 80,
        height = vim.o.lines - 3,
        border = 'rounded',
        headers = {
          user = '  ' .. ((vim.g.user or 'you'):gsub('^%l', string.upper)) .. ' ',
          assistant = '  Copilot ',
          tool = ' Tool: ',
        },
        show_folds = false,
      },

      -- Make submit explicit so you’re not relying on <Tab>
      mappings = {
        submit_prompt = {
          insert = '<C-s>', -- send while typing
          normal = '<CR>', -- send from normal mode
        },
      },
    }
  end,
}
