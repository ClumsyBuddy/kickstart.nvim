return {
  {
    'jmbuhr/otter.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
    enabled = false,
    -- enabled = function()
    --   return not vim.g.vscode
    -- end,
    config = function()
      local otter = require 'otter'
      otter.setup {
        lsp = {
          -- `:h events` that cause the diagnostics to update. Set to:
          -- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
          -- but more instant diagnostic updates
          diagnostic_update_events = { 'BufWritePost', 'InsertLeave', 'TextChanged' },
          -- Enable hover, completion, and other LSP features
          hover = {
            border = 'rounded',
          },
          -- function to find the root dir where the otter-ls is started
          root_dir = function(_, bufnr)
            return vim.fs.root(bufnr or 0, {
              '.git',
              '_quarto.yml',
              'package.json',
            }) or vim.fn.getcwd(0)
          end,
        },
        -- options related to the otter buffers
        buffers = {
          -- if set to true, the filetype of the otterbuffers will be set.
          -- otherwise only the autocommand of lspconfig that attaches
          -- the language server will be executed without setting the filetype
          --- this setting is deprecated and will default to true in the future
          set_filetype = true,
          -- write <path>.otter.<embedded language extension> files
          -- to disk on save of main buffer.
          -- usefule for some linters that require actual files.
          -- otter files are deleted on quit or main buffer close
          write_to_disk = true,
          -- a table of preambles for each language. The key is the language and the value is a table of strings that will be written to the otter buffer starting on the first line.
          preambles = {},
          -- a table of postambles for each language. The key is the language and the value is a table of strings that will be written to the end of the otter buffer.
          postambles = {},
          -- A table of patterns to ignore for each language. The key is the language and the value is a lua match pattern to ignore.
          -- lua patterns: https://www.lua.org/pil/20.2.html
          ignore_pattern = {
            -- ipython cell magic (lines starting with %) and shell commands (lines starting with !)
            python = '^(%s*[%%!].*)',
            -- ignore Angular template comments
            html = '<!--.-?-->',
          },
        },
        -- list of characters that should be stripped from the beginning and end of the code chunks
        strip_wrapping_quote_characters = { "'", '"', '`' },
        -- remove whitespace from the beginning of the code chunks when writing to the otter buffers
        -- and calculate it back in when handling lsp requests
        handle_leading_whitespace = true,
        -- mapping of filetypes to extensions for those not already included in otter.tools.extensions
        -- e.g. ["bash"] = "sh"
        extensions = {},
        -- add event listeners for LSP events for debugging
        debug = false,
        verbose = { -- set to true to see if code chunks are found
          no_code_found = true, -- warn if otter.activate is called, but no injected code was found
        },
      }
      -- vim.ai.nvim_create_autocmd('FileType', {
      --   pattern = { 'markdown', 'python', 'typescript', 'javascript', 'html', 'angular' },
      --   callback = function()
      --     otter.activate()
      --   end,
      -- })

      -- Create a user command to manually activate otter for debugging
      vim.api.nvim_create_user_command('OtterActivate', function()
        otter.activate()
        print 'Otter activated manually'
      end, {})

      -- Create a command to force otter sync
      vim.api.nvim_create_user_command('OtterForceSync', function()
        local bufnr = vim.api.nvim_get_current_buf()
        print 'Forcing otter to resync...'

        -- First deactivate any existing otter instance
        otter.deactivate()
        print 'Deactivated existing otter'

        -- Wait a moment and reactivate
        vim.defer_fn(function()
          otter.activate({ 'html', 'css', 'javascript' }, true)
          print 'Reactivated otter with explicit languages'
        end, 100)
      end, {})

      -- Create a command to show otter status
      vim.api.nvim_create_user_command('OtterStatus', function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = bufnr }
        print 'LSP clients for current buffer:'
        for _, client in ipairs(clients) do
          print('  - ' .. client.name)
        end
        print('Buffer filetype: ' .. vim.bo[bufnr].filetype)

        -- Check cursor position context
        local pos = vim.api.nvim_win_get_cursor(0)
        local row, col = pos[1], pos[2]
        print('Cursor position: line ' .. row .. ', col ' .. col)

        -- Check otter raft information
        local otter_keeper = require 'otter.keeper'
        if otter_keeper.rafts and otter_keeper.rafts[bufnr] then
          print 'Otter raft exists for current buffer'
          local raft = otter_keeper.rafts[bufnr]
          if raft.otters_attached then
            print 'Otter buffers attached:'
            for lang, otter_info in pairs(raft.otters_attached) do
              print('  - ' .. lang .. ' (bufnr: ' .. otter_info.bufnr .. ')')
            end
          else
            print 'No otter buffers attached'
          end

          -- Check if otter buffers exist even if not "attached"
          if raft.otters then
            print 'Otter buffers in raft.otters:'
            for lang, otter_info in pairs(raft.otters) do
              print('  - ' .. lang .. ' (bufnr: ' .. tostring(otter_info.bufnr) .. ')')
            end
          else
            print 'No otter buffers in raft.otters either'
          end

          -- Debug the raft contents
          print 'Full raft debug info:'
          for key, value in pairs(raft) do
            print('  raft.' .. key .. ' = ' .. tostring(value))
          end
        else
          print 'No otter raft exists for current buffer'
        end

        -- Test manual completion trigger
        print 'To test completions, position cursor in template string and press <C-Space>'

        -- Try to manually sync otter with existing temp files
        print '\nTrying to manually sync otter with temp files...'
        local html_bufnr = 19 -- The .otter.html buffer
        local css_bufnr = 18 -- The .otter.css buffer

        if vim.api.nvim_buf_is_valid(html_bufnr) then
          print('HTML temp buffer ' .. html_bufnr .. ' exists')
        end
        if vim.api.nvim_buf_is_valid(css_bufnr) then
          print('CSS temp buffer ' .. css_bufnr .. ' exists')
        end
      end, {})
    end,
  },
}
