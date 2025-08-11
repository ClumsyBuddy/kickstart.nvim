-- cspell: disable
return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>b', group = '[B]uffer' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>v', group = '[V]env' },
        { '<leader>dd', group = '[D]elete' },
        { '<leader>dy', group = '[Y]ank' },

        -- Surround (nvim-surround)
        { 'gs', group = '[S]urround' },

        -- Comment.nvim single-line toggle moved to `gl`
        { 'gl', desc = 'Toggle line comment', mode = 'n' },

        -- LSP references moved from `gr` -> `gR` (if you applied that change)
        { 'gR', desc = 'LSP References', mode = 'n' },

        -- Mini.ai next/last moved off a/i prefixes (if you applied that change)
        { 'gan', desc = 'Around Next', mode = { 'n', 'x', 'o' } },
        { 'gal', desc = 'Around Last', mode = { 'n', 'x', 'o' } },
        { 'gin', desc = 'Inside Next', mode = { 'n', 'x', 'o' } },
        { 'gil', desc = 'Inside Last', mode = { 'n', 'x', 'o' } },

        -- cspell actions
        { '<leader>ci', desc = 'cspell: ignore word', mode = 'n' },
        { '<leader>cw', desc = 'cspell: add word', mode = 'n' },
        { '<leader>cs', desc = 'cspell: use suggestion', mode = 'n' },
      },
    },
  },
}
