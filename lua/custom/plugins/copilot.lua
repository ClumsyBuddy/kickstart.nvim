return {
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
}

-- return {
--   'github/copilot.vim',
--   enabled = false,
--   config = function()
--     vim.keymap.set('i', '<C-Y>', 'copilot#Accept("\\<CR>")', {
--       expr = true,
--       replace_keycodes = false,
--     })
--     vim.g.copilot_no_tab_map = true
--   end,
-- }
--
--
