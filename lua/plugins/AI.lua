return {
  -- {
  --   'zbirenbaum/copilot.lua',
  --   enabled = function()
  --     return not vim.g.vscode
  --   end,
  --   cmd = 'Copilot',
  --   event = 'InsertEnter',
  --   config = function()
  --     require('copilot').setup {
  --       suggestion = {
  --         enabled = false,
  --         auto_trigger = true,
  --         debounce = 250,
  --         keymap = {
  --           accept = '<C-y>',
  --           accept_word = false,
  --           accept_line = false,
  --           next = '<M-]>',
  --           prev = '<M-[>',
  --           dismiss = '<C-]>',
  --         },
  --       },
  --       panel = { enabled = false },
  --     }
  --   end,
  -- },
  -- {
  --   'CopilotC-Nvim/CopilotChat.nvim',
  --   dependencies = { 'nvim-lua/plenary.nvim', 'MunifTanjim/nui.nvim', 'zbirenbaum/copilot.lua' },
  --   cmd = { 'CopilotChat', 'CopilotChatToggle', 'CopilotChatModels', 'CopilotChatCommit' },
  --   keys = {
  --     { '<leader>cc', ':CopilotChat<cr>', desc = 'CopilotChat: Open' },
  --     { '<leader>ccc', ':CopilotChatCommit<cr>', desc = 'CopilotChat: Commit', mode = { 'n', 'v' } },
  --   },
  --   config = function()
  --     require('CopilotChat').setup {
  --       provider = 'copilot',
  --       window = {
  --         layout = 'float',
  --       },
  --     }
  --   end,
  -- },
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
  {
    "sudo-tee/opencode.nvim",
    config = function()
      require('opencode').setup({
        preferred_picker = nil, -- 'telescope', 'fzf', 'mini.pick', 'snacks', 'select', if nil, it will use the best available picker. Note mini.pick does not support multiple selections
        preferred_completion = nil, -- 'blink', 'nvim-cmp','vim_complete' if nil, it will use the best available completion
        default_global_keymaps = true, -- If false, disables all default global keymaps
        default_mode = 'build', -- 'build' or 'plan' or any custom configured. @see [OpenCode Agents](https://opencode.ai/docs/modes/)
        keymap_prefix = '<leader>o', -- Default keymap prefix for global keymaps change to your preferred prefix and it will be applied to all keymaps starting with <leader>o
        opencode_executable = 'opencode', -- Name of your opencode binary
        keymap = {
          editor = {
            ['<leader>og'] = { 'toggle' }, -- Open opencode. Close if opened
            -- ['<leader>oi'] = { 'open_input' }, -- Opens and focuses on input window on insert mode
            -- ['<leader>oI'] = { 'open_input_new_session' }, -- Opens and focuses on input window on insert mode. Creates a new session
            -- ['<leader>oo'] = { 'open_output' }, -- Opens and focuses on output window
            -- ['<leader>ot'] = { 'toggle_focus' }, -- Toggle focus between opencode and last window
            -- ['<leader>oT'] = { 'timeline' }, -- Display timeline picker to navigate/undo/redo/fork messages
            -- ['<leader>oq'] = { 'close' }, -- Close UI windows
            -- ['<leader>os'] = { 'select_session' }, -- Select and load a opencode session
            -- ['<leader>oR'] = { 'rename_session' }, -- Rename current session
            -- ['<leader>op'] = { 'configure_provider' }, -- Quick provider and model switch from predefined list
            -- ['<leader>oz'] = { 'toggle_zoom' }, -- Zoom in/out on the Opencode windows
            -- ['<leader>ov'] = { 'paste_image'}, -- Paste image from clipboard into current session
            -- ['<leader>od'] = { 'diff_open' }, -- Opens a diff tab of a modified file since the last opencode prompt
            -- ['<leader>o]'] = { 'diff_next' }, -- Navigate to next file diff
            -- ['<leader>o['] = { 'diff_prev' }, -- Navigate to previous file diff
            -- ['<leader>oc'] = { 'diff_close' }, -- Close diff view tab and return to normal editing
            -- ['<leader>ora'] = { 'diff_revert_all_last_prompt' }, -- Revert all file changes since the last opencode prompt
            -- ['<leader>ort'] = { 'diff_revert_this_last_prompt' }, -- Revert current file changes since the last opencode prompt
            -- ['<leader>orA'] = { 'diff_revert_all' }, -- Revert all file changes since the last opencode session
            -- ['<leader>orT'] = { 'diff_revert_this' }, -- Revert current file changes since the last opencode session
            -- ['<leader>orr'] = { 'diff_restore_snapshot_file' }, -- Restore a file to a restore point
            -- ['<leader>orR'] = { 'diff_restore_snapshot_all' }, -- Restore all files to a restore point
            ['<leader>ox'] = { 'swap_position' }, -- Swap Opencode pane left/right
            ['<leader>opa'] = { 'permission_accept' }, -- Accept permission request once
            ['<leader>opA'] = { 'permission_accept_all' }, -- Accept all (for current tool)
            ['<leader>opd'] = { 'permission_deny' }, -- Deny permission request once
            -- ['<leader>ott'] = { 'toggle_tool_output' }, -- Toggle tools output (diffs, cmd output, etc.)
            -- ['<leader>otr'] = { 'toggle_reasoning_output' }, -- Toggle reasoning output (thinking steps)
            ['<leader>o/'] = { 'quick_chat', mode = { 'n', 'x' } }, -- Open quick chat input with selection context in visual mode or current line context in normal mode
          },
          input_window = {
            ['<cr>'] = { 'submit_input_prompt', mode = { 'n', 'i' } }, -- Submit prompt (normal mode and insert mode)
            ['<esc>'] = { 'close' }, -- Close UI windows
            ['<C-c>'] = { 'cancel' }, -- Cancel opencode request while it is running
            ['~'] = { 'mention_file', mode = 'i' }, -- Pick a file and add to context. See File Mentions section
            ['@'] = { 'mention', mode = 'i' }, -- Insert mention (file/agent)
            ['/'] = { 'slash_commands', mode = 'i' }, -- Pick a command to run in the input window
            ['#'] = { 'context_items', mode = 'i' }, -- Manage context items (current file, selection, diagnostics, mentioned files)
            ['<M-v>'] = { 'paste_image', mode = 'i' }, -- Paste image from clipboard as attachment
            ['<C-i>'] = { 'focus_input', mode = { 'n', 'i' } }, -- Focus on input window and enter insert mode at the end of the input from the output window
            ['<tab>'] = { 'toggle_pane', mode = { 'n', 'i' } }, -- Toggle between input and output panes
            ['<up>'] = { 'prev_prompt_history', mode = { 'n', 'i' } }, -- Navigate to previous prompt in history
            ['<down>'] = { 'next_prompt_history', mode = { 'n', 'i' } }, -- Navigate to next prompt in history
            ['<M-m>'] = { 'switch_mode' }, -- Switch between modes (build/plan)
          },
          output_window = {
            ['<esc>'] = { 'close' }, -- Close UI windows
            ['<C-c>'] = { 'cancel' }, -- Cancel opencode request while it is running
            [']]'] = { 'next_message' }, -- Navigate to next message in the conversation
            ['[['] = { 'prev_message' }, -- Navigate to previous message in the conversation
            ['<tab>'] = { 'toggle_pane', mode = { 'n', 'i' } }, -- Toggle between input and output panes
            ['i'] = { 'focus_input', 'n' }, -- Focus on input window and enter insert mode at the end of the input from the output window
            ['<leader>oS'] = { 'select_child_session' }, -- Select and load a child session
            ['<leader>oD'] = { 'debug_message' }, -- Open raw message in new buffer for debugging
            ['<leader>oO'] = { 'debug_output' }, -- Open raw output in new buffer for debugging
            ['<leader>ods'] = { 'debug_session' }, -- Open raw session in new buffer for debugging
          },
          permission = {
            accept = 'a', -- Accept permission request once (only available when there is a pending permission request)
            accept_all = 'A', -- Accept all (for current tool) permission request once (only available when there is a pending permission request)
            deny = 'd', -- Deny permission request once (only available when there is a pending permission request)
          },
          session_picker = {
            rename_session = { '<C-r>' }, -- Rename selected session in the session picker
            delete_session = { '<C-d>' }, -- Delete selected session in the session picker
            new_session = { '<C-n>' }, -- Create and switch to a new session in the session picker
          },
          timeline_picker = {
            undo = { '<C-u>', mode = { 'i', 'n' } }, -- Undo to selected message in timeline picker
            fork = { '<C-f>', mode = { 'i', 'n' } }, -- Fork from selected message in timeline picker
          },
          history_picker = {
            delete_entry = { '<C-d>', mode = { 'i', 'n' } }, -- Delete selected entry in the history picker
            clear_all = { '<C-X>', mode = { 'i', 'n' } }, -- Clear all entries in the history picker
          },
          model_picker = {
            toggle_favorite = { '<C-f>', mode = { 'i', 'n' } },
          },
          mcp_picker = {
            toggle_connection = { '<C-t>', mode = { 'i', 'n' } }, -- Toggle MCP server connection in the MCP picker
          },
        },
        ui = {
          position = 'right', -- 'right' (default), 'left' or 'current'. Position of the UI split. 'current' uses the current window for the output.
          input_position = 'bottom', -- 'bottom' (default) or 'top'. Position of the input window
          window_width = 0.40, -- Width as percentage of editor width
          zoom_width = 0.8, -- Zoom width as percentage of editor width
          input_height = 0.15, -- Input height as percentage of window height
          display_model = true, -- Display model name on top winbar
          display_context_size = true, -- Display context size in the footer
          display_cost = true, -- Display cost in the footer
          window_highlight = 'Normal:OpencodeBackground,FloatBorder:OpencodeBorder', -- Highlight group for the opencode window
          icons = {
            preset = 'nerdfonts', -- 'nerdfonts' | 'text'. Choose UI icon style (default: 'nerdfonts')
            overrides = {}, -- Optional per-key overrides, see section below
          },
          output = {
            tools = {
              show_output = true, -- Show tools output [diffs, cmd output, etc.] (default: true)
              show_reasoning_output = true, -- Show reasoning/thinking steps output (default: true)
            },
            rendering = {
              markdown_debounce_ms = 250, -- Debounce time for markdown rendering on new data (default: 250ms)
              on_data_rendered = nil, -- Called when new data is rendered; set to false to disable default RenderMarkdown/Markview behavior
            },
          },
          input = {
            text = {
              wrap = false, -- Wraps text inside input window
            },
          },
          picker = {
            snacks_layout = nil -- `layout` opts to pass to Snacks.picker.pick({ layout = ... })
          },
          completion = {
            file_sources = {
              enabled = true,
              preferred_cli_tool = 'server', -- 'fd','fdfind','rg','git','server' if nil, it will use the best available tool, 'server' uses opencode cli to get file list (works cross platform) and supports folders
              ignore_patterns = {
                '^%.git/',
                '^%.svn/',
                '^%.hg/',
                'node_modules/',
                '%.pyc$',
                '%.o$',
                '%.obj$',
                '%.exe$',
                '%.dll$',
                '%.so$',
                '%.dylib$',
                '%.class$',
                '%.jar$',
                '%.war$',
                '%.ear$',
                'target/',
                'build/',
                'dist/',
                'out/',
                'deps/',
                '%.tmp$',
                '%.temp$',
                '%.log$',
                '%.cache$',
              },
              max_files = 10,
              max_display_length = 50, -- Maximum length for file path display in completion, truncates from left with "..."
            },
          },
        },
        context = {
          enabled = true, -- Enable automatic context capturing
          cursor_data = {
            enabled = false, -- Include cursor position and line content in the context
            context_lines = 5, -- Number of lines before and after cursor to include in context
          },
          diagnostics = {
            info = false, -- Include diagnostics info in the context (default to false
            warn = true, -- Include diagnostics warnings in the context
            error = true, -- Include diagnostics errors in the context
            only_closest = false, -- If true, only diagnostics for cursor/selection
          },
          current_file = {
            enabled = true, -- Include current file path and content in the context
            show_full_path = true,
          },
          files = {
            enabled = true,
            show_full_path = true,
          },
          selection = {
            enabled = true, -- Include selected text in the context
          },
          buffer = {
            enabled = false, -- Disable entire buffer context by default, only used in quick chat
          },
          git_diff = {
            enabled = false,
          },
        },
        debug = {
          enabled = false, -- Enable debug messages in the output window
          capture_streamed_events = false,
          show_ids = true,
          quick_chat = {
            keep_session = false, -- Keep quick_chat sessions for inspection, this can pollute your sessions list
            set_active_session = false,
          },
        },
        prompt_guard = nil, -- Optional function that returns boolean to control when prompts can be sent (see Prompt Guard section)

        -- User Hooks for custom behavior at certain events
        hooks = {
          on_file_edited = nil, -- Called after a file is edited by opencode.
          on_session_loaded = nil, -- Called after a session is loaded.
          on_done_thinking = nil, -- Called when opencode finishes thinking (all jobs complete).
          on_permission_requested = nil, -- Called when a permission request is issued.
        },
        quick_chat = {
          default_model = nil,   -- works better with a fast model like gpt-4.1
          default_agent = 'plan', -- plan ensure no file modifications by default
          instructions = nil, -- Use built-in instructions if nil
        },
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { 'markdown', 'opencode_output' },
        },
        ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
      },
      -- Optional, for file mentions and commands completion, pick only one
      -- 'saghen/blink.cmp',
      'hrsh7th/nvim-cmp',

      -- Optional, for file mentions picker, pick only one
      'folke/snacks.nvim',
      -- 'nvim-telescope/telescope.nvim',
      -- 'ibhagwan/fzf-lua',
      -- 'nvim_mini/mini.nvim',
    },
  },
  {
          "ThePrimeagen/99",
          config = function()
                  local _99 = require("99")

      -- For logging that is to a file if you wish to trace through requests
      -- for reporting bugs, i would not rely on this, but instead the provided
      -- logging mechanisms within 99.  This is for more debugging purposes
      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)
                  _99.setup({
                          model = "github-copilot/claude-opus-4.5",
                          logger = {
                                  level = _99.DEBUG,
                                  path = vim.fn.stdpath("cache") .. "/" .. basename .. ".99.debug",
                                  print_on_error = true,
                          },

          --- A new feature that is centered around tags
          completion = {
              --- Defaults to .cursor/rules
              -- I am going to disable these until i understand the
              -- problem better.  Inside of cursor rules there is also
              -- application rules, which means i need to apply these
              -- differently
              -- cursor_rules = "<custom path to cursor rules>"

              --- A list of folders where you have your own SKILL.md
              --- Expected format:
              --- /path/to/dir/<skill_name>/SKILL.md
              ---
              --- Example:
              --- Input Path:
              --- "scratch/custom_rules/"
              ---
              --- Output Rules:
              --- {path = "scratch/custom_rules/vim/SKILL.md", name = "vim"},
              --- ... the other rules in that dir ...
              ---
              custom_rules = {
                "scratch/custom_rules/",
              },

              --- What autocomplete do you use.  We currently only
              --- support cmp right now
              source = "cmp",
          },

          --- WARNING: if you change cwd then this is likely broken
          --- ill likely fix this in a later change
          ---
          --- md_files is a list of files to look for and auto add based on the location
          --- of the originating request.  That means if you are at /foo/bar/baz.lua
          --- the system will automagically look for:
          --- /foo/bar/AGENT.md
          --- /foo/AGENT.md
          --- assuming that /foo is project root (based on cwd)
                          md_files = {
                                  "AGENT.md",
                          },
                  })

      -- Create your own short cuts for the different types of actions
                  vim.keymap.set("n", "<leader>9f", function()
                          _99.fill_in_function()
                  end)
      -- take extra note that i have visual selection only in v mode
      -- technically whatever your last visual selection is, will be used
      -- so i have this set to visual mode so i dont screw up and use an
      -- old visual selection
      --
      -- likely ill add a mode check and assert on required visual mode
      -- so just prepare for it now
                  vim.keymap.set("v", "<leader>9v", function()
                          _99.visual()
                  end)

      --- if you have a request you dont want to make any changes, just cancel it
                  vim.keymap.set("v", "<leader>9s", function()
                          _99.stop_all_requests()
                  end)

      --- Example: Using rules + actions for custom behaviors
      --- Create a rule file like ~/.rules/debug.md that defines custom behavior.
      --- For instance, a "debug" rule could automatically add printf statements
      --- throughout a function to help debug its execution flow.
                  vim.keymap.set("n", "<leader>9fd", function()
                          _99.fill_in_function()
                  end)
          end,
  },
}
