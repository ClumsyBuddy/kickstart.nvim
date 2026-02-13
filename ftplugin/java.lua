-- ftplugin/java.lua
-- This file runs automatically when you open a .java file
-- It configures and starts jdtls for the current project

-- Paths to Mason-installed jdtls
local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'
local jdtls_bin = mason_path .. '/bin/jdtls'

-- Bail out if jdtls isn't installed yet
if vim.fn.executable(jdtls_bin) == 0 then
  vim.notify('jdtls not found. Run :MasonInstall jdtls', vim.log.levels.WARN)
  return
end

-- Find the project root (look for build.gradle, pom.xml, or .git)
local root_markers = { 'build.gradle', 'build.gradle.kts', 'pom.xml', '.git', 'mvnw', 'gradlew' }
local root_dir = vim.fs.dirname(vim.fs.find(root_markers, { upward = true })[1])

-- Each project needs its own workspace folder for jdtls metadata
-- We create a unique folder based on the project path
local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/jdtls-workspace/' .. project_name

-- Java runtime from SDKMAN (Java 25 for Hytale)
local java_home = os.getenv('JAVA_HOME') or vim.fn.expand('~/.sdkman/candidates/java/current')

local config = {
  cmd = {
    jdtls_bin,
    '-data', workspace_dir,
  },

  root_dir = root_dir,

  settings = {
    java = {
      home = java_home,
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      configuration = {
        updateBuildConfiguration = 'interactive',
        -- Tell jdtls about your installed JDKs
        runtimes = {
          {
            name = 'JavaSE-25',
            path = java_home,
            default = true,
          },
        },
      },
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' }, -- Decompiler for viewing library source
      completion = {
        favoriteStaticMembers = {
          'org.junit.Assert.*',
          'org.junit.jupiter.api.Assertions.*',
          'java.util.Objects.requireNonNull',
          'java.util.Objects.requireNonNullElse',
        },
        importOrder = { 'java', 'javax', 'com', 'org' },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
    },
  },

  init_options = {
    bundles = {}, -- Add debug/test bundles here later if needed
  },
}

-- Start jdtls with this config
require('jdtls').start_or_attach(config)

-- Java-specific keymaps (only active in Java buffers)
local opts = { buffer = true, silent = true }
vim.keymap.set('n', '<leader>jo', require('jdtls').organize_imports, vim.tbl_extend('force', opts, { desc = 'Organize imports' }))
vim.keymap.set('n', '<leader>jv', require('jdtls').extract_variable, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
vim.keymap.set('v', '<leader>jv', function() require('jdtls').extract_variable(true) end, vim.tbl_extend('force', opts, { desc = 'Extract variable' }))
vim.keymap.set('n', '<leader>jc', require('jdtls').extract_constant, vim.tbl_extend('force', opts, { desc = 'Extract constant' }))
vim.keymap.set('v', '<leader>jc', function() require('jdtls').extract_constant(true) end, vim.tbl_extend('force', opts, { desc = 'Extract constant' }))
vim.keymap.set('v', '<leader>jm', function() require('jdtls').extract_method(true) end, vim.tbl_extend('force', opts, { desc = 'Extract method' }))
