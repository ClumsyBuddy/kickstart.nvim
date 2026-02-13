-- Java development support via nvim-jdtls
-- This plugin provides enhanced Java LSP features beyond what lspconfig offers
return {
  'mfussenegger/nvim-jdtls',
  ft = 'java', -- Only load when opening Java files
  dependencies = {
    'williamboman/mason.nvim', -- jdtls is installed via Mason
  },
  -- No config here! Configuration happens in ftplugin/java.lua
  -- This is because jdtls needs to be started fresh for each project
  -- with project-specific settings (workspace path, etc.)
}
