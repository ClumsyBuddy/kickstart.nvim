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
          enabled = true,
          auto_trigger = true,
          debounce = 100,
          keymap = {
            accept = '<C-y>',
            accept_word = false,
            accept_line = false,
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        panel = { enabled = true },
        filetypes = {
          yaml = true,
          markdown = true,
        },
      }
    end,
  },
  {
    "ThePrimeagen/99",
    config = function()
      local _99 = require("99")

      -- Detect OS
      local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

      local cwd = vim.uv.cwd()
      local basename = vim.fs.basename(cwd)

      -- Use appropriate paths based on OS
      local log_path
      if is_windows then
        log_path = vim.fn.stdpath("cache") .. "\\" .. basename .. ".99.debug"
      else
        log_path = "/tmp/" .. basename .. ".99.debug"
      end

      _99.setup({
        model = "github-copilot/claude-opus-4.5",
        logger = {
          level = _99.DEBUG,
          path = log_path,
          print_on_error = true,
        },

        -- Relative path works on both Windows and Linux
        tmp_dir = "./tmp",

        completion = {
          source = "cmp",
          -- Enable @file autocompletion
          files = {
            enabled = true,
          },
        },

        -- Auto-add AGENT.md files based on file location
        md_files = {
          "AGENT.md",
        },
      })

      -- Visual mode: send selection with prompt
      vim.keymap.set("v", "<leader>9v", function()
        _99.visual()
      end)

      -- Search across project
      vim.keymap.set("n", "<leader>9s", function()
        _99.search()
      end)

      -- Stop all in-flight requests
      vim.keymap.set("n", "<leader>9x", function()
        _99.stop_all_requests()
      end)

      -- Telescope: select model
      vim.keymap.set("n", "<leader>9m", function()
        require("99.extensions.telescope").select_model()
      end)

      -- Telescope: select provider
      vim.keymap.set("n", "<leader>9p", function()
        require("99.extensions.telescope").select_provider()
      end)
    end,
  },
  {
    "piersolenski/wtf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      provider = "copilot",
    },
    keys = {
      {
        "<leader>wd",
        mode = { "n", "x" },
        function()
          require("wtf").diagnose()
        end,
        desc = "Debug diagnostic with AI",
      },
      {
        "<leader>wf",
        mode = { "n", "x" },
        function()
          require("wtf").fix()
        end,
        desc = "Fix diagnostic with AI",
      },
      {
        "<leader>ws",
        mode = { "n" },
        function()
          require("wtf").search()
        end,
        desc = "Search diagnostic with Google",
      },
      {
        "<leader>wh",
        mode = { "n" },
        function()
          require("wtf").history()
        end,
        desc = "Populate quickfix with diagnostic history",
      },
    },
  },
}
