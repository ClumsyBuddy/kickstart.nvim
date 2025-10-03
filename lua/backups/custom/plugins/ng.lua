return {
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
}
