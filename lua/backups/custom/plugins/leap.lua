return {
  {
    'ggandor/leap.nvim',
    enabled = false,
    config = function()
      require('leap').create_default_mappings()
      vim.keymap.set({ 'n', 'x' }, 's', '<Plug>(leap)')
    end,
    opts = {
      keymaps = {
        normal = 'ys',
        delete = 'ds',
        visual = 'S',
        visual_line = 'gS',
        change = 'cs',
        change_line = 'cS',
      },
    },
  },
}
