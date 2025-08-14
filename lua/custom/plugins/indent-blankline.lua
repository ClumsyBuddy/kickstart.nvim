local highlight = {
  'RainbowRed',
  'RainbowYellow',
  'RainbowBlue',
  'RainbowOrange',
  'RainbowGreen',
  'RainbowViolet',
  'RainbowCyan',
}

local hooks = require 'ibl.hooks'
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E06C75' })
  vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E5C07B' })
  vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
  vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D19A66' })
  vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
  vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
  vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
end)

-- hooks.register(hooks.type.VIRTUAL_TEXT, function(_, bufnr, row, virt_text)
--   local text = vim.api.nvim_buf_get_text(bufnr, row, 0, row, -1, {})[1]
--   if #text == 0 then
--     for _, vt in ipairs(virt_text) do
--       vt[1] = ' '
--     end
--   end
--   return virt_text
-- end)

return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  ---@module "ibl"
  ---@type ibl.config
  config = function()
    require('ibl').setup {
      indent = {
        highlight = highlight,
        -- Use dot for indedtation character
        -- char = '∘',
        char = '·',
        -- char = { '∘', '·' },
        tab_char = '»',
      },
      scope = {
        char = '┃',
      },
    }
  end,
}
