return {
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
      require('nvim-autopairs').remove_rule '`'
    end,
  },

  { -- completion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-emoji',
      'saadparwaiz1/cmp_luasnip',
      'f3fora/cmp-spell',
      'ray-x/cmp-treesitter',
      'kdheepak/cmp-latex-symbols',
      'jmbuhr/cmp-pandoc-references',
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
      'onsails/lspkind-nvim',
      'jmbuhr/otter.nvim',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
      end

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = {
          ['<C-f>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),

          ['<C-n>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-p>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<c-y>'] = cmp.mapping.confirm {
            select = true,
          },
          ['<CR>'] = cmp.mapping.confirm {
            select = true,
          },

          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },
        autocomplete = false,

        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol',
            menu = {
              otter = '[🦦]',
              nvim_lsp = '[LSP]',
              luasnip = '[snip]',
              buffer = '[buf]',
              path = '[path]',
              spell = '[spell]',
              pandoc_references = '[ref]',
              tags = '[tag]',
              treesitter = '[TS]',
              calc = '[calc]',
              latex_symbols = '[tex]',
              emoji = '[emoji]',
            },
          },
        },
        sources = {
          -- { name = 'otter' }, -- for code chunks in quarto
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip', keyword_length = 3, max_item_count = 3 },
          { name = 'pandoc_references' },
          { name = 'buffer', keyword_length = 5, max_item_count = 3 },
          { name = 'spell' },
          { name = 'treesitter', keyword_length = 5, max_item_count = 3 },
          { name = 'calc' },
          { name = 'latex_symbols' },
          { name = 'emoji' },
        },
        view = {
          entries = 'native',
        },
        window = {
          documentation = {
            border = require('misc.style').border,
          },
        },
      }

      -- for friendly snippets
      require('luasnip.loaders.from_vscode').lazy_load()
      -- for custom snippets
      require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snips' } }
      -- link quarto and rmarkdown to markdown snippets
      luasnip.filetype_extend('quarto', { 'markdown' })
      luasnip.filetype_extend('rmarkdown', { 'markdown' })
    end,
  },

  { -- gh copilot
    'zbirenbaum/copilot.lua',
    enabled = true,
    config = function()
      require('copilot').setup {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = '<c-a>',
            accept_word = false,
            accept_line = false,
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        panel = { enabled = false },
      }
    end,
  },
  {
    'joeveiga/ng.nvim',
    enabled = function()
      return not vim.g.vscode
    end,
    config = function()
      local ng = require 'ng'
      vim.keymap.set('n', '<leader>cat', ng.goto_template_for_component, { desc = 'Go to template for component', noremap = true, silent = true })
      vim.keymap.set('n', '<leader>cac', ng.goto_component_with_template_file, { desc = 'Go to component with template file', noremap = true, silent = true })
      vim.keymap.set('n', '<leader>caT', ng.get_template_tcb, { desc = 'Get template TCB', noremap = true, silent = true })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    enabled = function()
      return not vim.g.vscode
    end,
    dependencies = { { 'nvim-lua/plenary.nvim', branch = 'master' } },
    cmd = { 'CopilotChat', 'CopilotChatToggle', 'CopilotChatModels' },
    keys = {
      {
        '<leader>at',
        function()
          require('CopilotChat').toggle()
        end,
        desc = 'CopilotChat: Toggle',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ac',
        function()
          require('CopilotChat').reset()
        end,
        desc = 'CopilotChat: Clear',
        mode = { 'n', 'v' },
      },
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
  },
}
