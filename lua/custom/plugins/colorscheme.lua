return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    enabled = true,
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      -- vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
  {
    'Mofiqul/vscode.nvim',
    enabled = true,
    priority = 1001,
    opts = {
      transparent = true,

      -- Enable italic comment
      italic_comments = true,

      -- Underline `@markup.link.*` variants
      underline_links = true,

      -- Disable nvim-tree background color
      disable_nvimtree_bg = true,

      -- Apply theme colors to terminal
      terminal_colors = true,

      -- Override colors (see ./lua/vscode/colors.lua)
      color_overrides = {
        vscLineNumber = '#FFFFFF',
      },

      -- Override highlight groups (see ./lua/vscode/theme.lua)
    },
    config = function()
      -- local c = require('vscode.colors').get_colors()
      vim.cmd.colorscheme 'vscode'

      -- vim.cmd [[colorscheme visual_studio_code]]
    end,
    enabled = true,
  },
  { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  {
    'scottmckendry/cyberdream.nvim',
    dev = false,
    lazy = false,
    priority = 1000,
    config = function()
      require('cyberdream').setup {
        variant = 'auto',
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        terminal_colors = false,
        cache = true,
        borderless_pickers = true,
        overrides = function(c)
          return {
            CursorLine = { bg = c.bg },
            CursorLineNr = { fg = c.magenta },
          }
        end,
      }

      vim.cmd 'colorscheme cyberdream'
    end,
  },
}
