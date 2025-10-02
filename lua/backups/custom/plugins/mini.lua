return {

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup {
        n_lines = 500,
        -- Move "next/last" off the bare a/i prefixes to avoid overlap waits
        mappings = {
          around = 'a',
          inside = 'i',
          around_next = 'gan',
          around_last = 'gal',
          inside_next = 'gin',
          inside_last = 'gil',
        },
      }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      -- If you ever want Mini.surround instead of nvim-surround, you can enable below and pick non-overlapping keys.
      -- require('mini.surround').setup {
      --   mappings = {
      --     add = 'msa',
      --     delete = 'msd',
      --     find = 'msf',
      --     find_left = 'msF',
      --     highlight = 'msh',
      --     replace = 'msr',
      --     update_n_lines = 'msn',
      --     suffix_last = 'l',
      --     suffix_next = 'n',
      --   },
      --   silent = false,
      -- }

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      local u_icons = not vim.g.vscode
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = u_icons }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
