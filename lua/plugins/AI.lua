-- return {
--   'CopilotC-Nvim/CopilotChat.nvim',
--   enabled = function()
--     return not vim.g.vscode
--   end,
--   dependencies = {
--     { 'nvim-lua/plenary.nvim', branch = 'master' },
--   },
--   cmd = { 'CopilotChat', 'CopilotChatToggle', 'CopilotChatModels' },
--   keys = {
--     {
--       '<leader>at',
--       function()
--         require('CopilotChat').toggle()
--       end,
--       desc = 'CopilotChat: Toggle',
--       mode = { 'n', 'v' },
--     },
--     {
--       '<leader>ac',
--       function()
--         require('CopilotChat').reset()
--       end,
--       desc = 'CopilotChat: Clear',
--       mode = { 'n', 'v' },
--     },
--   },
--   config = function()
--     vim.api.nvim_create_autocmd('BufEnter', {
--       pattern = 'copilot-chat',
--       callback = function()
--         vim.opt_local.relativenumber = false
--         vim.opt_local.number = false
--       end,
--     })
--
--     require('CopilotChat').setup {
--       -- Use Copilot provider; enable GitHub Models for Claude/Gemini/etc. (Copilot Pro)
--       provider = 'copilot',
--       providers = { github_models = { enabled = true } },
--
--       -- Check available names with :CopilotChatModels (e.g., 'claude-3.5-sonnet', 'gpt-4.1', etc.)
--       model = 'gpt-4.1',
--
--       auto_insert_mode = true,
--
--       window = {
--         layout = 'float',
--         relative = 'editor',
--         row = 0,
--         col = vim.o.columns - 80,
--         width = 80,
--         height = vim.o.lines - 3,
--         border = 'rounded',
--         headers = {
--           user = '  ' .. ((vim.g.user or 'you'):gsub('^%l', string.upper)) .. ' ',
--           assistant = '  Copilot ',
--           tool = ' Tool: ',
--         },
--         show_folds = false,
--       },
--
--       -- Make submit explicit so you’re not relying on <Tab>
--       mappings = {
--         complete = {
--           insert = '<C-a>', -- manually trigger completion
--         },
--         submit_prompt = {
--           insert = '<C-s>', -- send while typing
--           normal = '<CR>', -- send from normal mode
--         },
--       },
--     }
--   end,
-- }
--
return {
  {
    'zbirenbaum/copilot.lua',
    enabled = function()
      return not vim.g.vscode
    end,
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = false,
          auto_trigger = true,
          debounce = 250,
          keymap = {
            accept = '<C-y>',
            accept_word = false,
            accept_line = false,
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        panel = { enabled = false }, -- set to true if you want the side panel
      }
    end,
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'ravitemer/mcphub.nvim',
      {
        'echasnovski/mini.diff',
        config = function()
          local diff = require 'mini.diff'
          diff.setup {
            -- Disabled by default
            source = diff.gen_source.none(),
          }
        end,
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'codecompanion' },
      },
    },
    opts = {
      -- NOTE: The log_level is in `opts.opts`
      opts = {
        log_level = 'DEBUG', -- or "TRACE"
      },
    },
    config = function()
      require('codecompanion').setup {
        extensions = {
          mcphub = {
            callback = 'mcphub.extensions.codecompanion',
            opts = {
              make_vars = true,
              make_slash_commands = true,
              show_result_in_chat = true,
            },
          },
        },
        strategies = {
          chat = {
            adapter = 'copilot',
            model = 'claude-sonnet-4',
          },
          inline = {
            adapter = 'copilot',
            model = 'claude-sonnet-4',
          },
          cmd = {
            adapter = 'copilot',
            model = 'claude-sonnet-4',
          },
        },
      }
    end,
    keys = {
      {
        '<leader>aa',
        mode = { 'n' },
        function()
          vim.cmd 'CodeCompanionActions'
        end,
        desc = 'CodeCompanion: Actions',
      },
    },
  },
  {
    'piersolenski/wtf.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      -- Optional: For WtfGrepHistory (pick one)
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
