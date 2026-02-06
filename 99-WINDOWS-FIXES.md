# ThePrimeagen/99 Plugin - Windows & OpenCode Compatibility Fixes

This document describes the changes required to make the `99` Neovim plugin work on Windows and with the `opencode` CLI.

## Issues Addressed

1. **Windows Path Compatibility**: The plugin uses Unix-style `/tmp/` paths which don't exist on Windows
2. **OpenCode Provider Output**: The `OpenCodeProvider` expects the LLM to write directly to a temp file, but `opencode run` outputs to stdout
3. **Markdown Code Fences**: `opencode run` wraps code output in markdown fences (```lang ... ```) which need to be stripped
4. **Temp File Cleanup**: Temp files and the `.99-tmp` directory accumulate and are never cleaned up

---

## File 1: `lua/99/utils.lua`

### Problem
The `random_file()` function uses hardcoded paths that don't work on Windows:
```lua
-- Original (broken on Windows)
local filepath = cwd .. "/tmp/99-" .. math.floor(math.random() * 10000)
```

### Solution
Use a project-local `.99-tmp` directory and create it if it doesn't exist:

```lua
local M = {}

-- Track temp files for cleanup
M._temp_files = {}

--- TODO: some people change their current working directory as they open new
--- directories.  if this is still the case in neovim land, then we will need
--- to make the _99_state have the project directory.
--- @return string
function M.random_file()
  local cwd = vim.uv.cwd()
  local temp_dir = cwd .. "/.99-tmp"
  vim.fn.mkdir(temp_dir, "p")
  local filepath = temp_dir .. "/99-" .. math.floor(math.random() * 10000)
  -- Track for cleanup
  table.insert(M._temp_files, filepath)
  return filepath
end

--- Clean up a specific temp file and its associated prompt file
--- @param filepath string
function M.cleanup_file(filepath)
  pcall(function()
    os.remove(filepath)
    os.remove(filepath .. "-prompt")
  end)
  -- Remove from tracking
  for i, f in ipairs(M._temp_files) do
    if f == filepath then
      table.remove(M._temp_files, i)
      break
    end
  end
end

--- Clean up all tracked temp files
function M.cleanup_all()
  for _, filepath in ipairs(M._temp_files) do
    pcall(function()
      os.remove(filepath)
      os.remove(filepath .. "-prompt")
    end)
  end
  M._temp_files = {}
end

--- Clean up the entire .99-tmp directory for the current project
function M.cleanup_temp_dir()
  local cwd = vim.uv.cwd()
  local temp_dir = cwd .. "/.99-tmp"
  -- Remove all files in the directory
  local handle = vim.loop.fs_scandir(temp_dir)
  if handle then
    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then break end
      if type == "file" then
        pcall(function() os.remove(temp_dir .. "/" .. name) end)
      end
    end
  end
  -- Remove the directory itself
  pcall(function() vim.loop.fs_rmdir(temp_dir) end)
  M._temp_files = {}
end

return M
```

### Notes
- Users should add `.99-tmp/` to their `.gitignore`
- Alternative: Use `vim.fn.stdpath("cache") .. "/99-tmp"` for a global cache location
- Call `require("99.utils").cleanup_temp_dir()` to clean up all temp files manually

---

## File 2: `lua/99/providers.lua`

### Problem
The `OpenCodeProvider` inherits `make_request` from `BaseProvider`, which expects the LLM to write its response to a temp file. However, `opencode run` outputs to stdout and doesn't write files.

Additionally, `opencode run` wraps code in markdown fences:
```
```python
def hello():
    print("hello")
```
```

But the plugin expects raw code without any wrapping.

### Solution
Override `make_request` for `OpenCodeProvider` to:
1. Accumulate stdout from the `opencode run` command
2. Strip markdown code fences from the output
3. Write the cleaned output to the temp file

Add this method to `OpenCodeProvider` (after line 155, before `ClaudeCodeProvider`):

```lua
--- OpenCode outputs to stdout instead of writing to temp file, so we need to
--- capture stdout and write it to the temp file ourselves
--- @param query string
--- @param request _99.Request
--- @param observer _99.Providers.Observer?
function OpenCodeProvider:make_request(query, request, observer)
  local logger = request.logger:set_area(self:_get_provider_name())
  logger:debug("make_request", "tmp_file", request.context.tmp_file)

  observer = observer or DevNullObserver
  local once_complete = once(function(status, text)
    observer.on_complete(status, text)
  end)

  local command = self:_build_command(query, request)
  logger:debug("make_request", "command", command)

  -- Accumulate stdout to write to temp file
  local stdout_lines = {}

  local proc = vim.system(
    command,
    {
      text = true,
      stdout = vim.schedule_wrap(function(err, data)
        logger:debug("stdout", "data", data)
        if request:is_cancelled() then
          once_complete("cancelled", "")
          return
        end
        if err and err ~= "" then
          logger:debug("stdout#error", "err", err)
        end
        if not err and data then
          table.insert(stdout_lines, data)
          observer.on_stdout(data)
        end
      end),
      stderr = vim.schedule_wrap(function(err, data)
        logger:debug("stderr", "data", data)
        if request:is_cancelled() then
          once_complete("cancelled", "")
          return
        end
        if err and err ~= "" then
          logger:debug("stderr#error", "err", err)
        end
        if not err then
          observer.on_stderr(data)
        end
      end),
    },
    vim.schedule_wrap(function(obj)
      if request:is_cancelled() then
        once_complete("cancelled", "")
        logger:debug("on_complete: request has been cancelled")
        return
      end
      if obj.code ~= 0 then
        local str =
          string.format("process exit code: %d\n%s", obj.code, vim.inspect(obj))
        once_complete("failed", str)
        logger:fatal(
          self:_get_provider_name() .. " make_query failed",
          "obj from results",
          obj
        )
      else
        vim.schedule(function()
          -- Write accumulated stdout to temp file
          local output = table.concat(stdout_lines, "")
          
          -- Strip markdown code fences from opencode output
          -- Find first ``` and last ```, extract content between
          local fence_start = output:find("```[%w]*\n")
          local fence_end = output:find("\n```", fence_start or 1)
          if fence_start and fence_end then
            -- Find the end of the opening fence line
            local content_start = output:find("\n", fence_start) + 1
            output = output:sub(content_start, fence_end - 1)
          end
          
          local tmp = request.context.tmp_file
          local write_ok, write_err = pcall(function()
            local file = io.open(tmp, "w")
            if file then
              file:write(output)
              file:close()
            else
              error("Could not open file for writing: " .. tmp)
            end
          end)
          if not write_ok then
            logger:error("failed to write stdout to temp file", "error", write_err)
            once_complete("failed", "unable to write response to temp file")
            return
          end
          local ok, res = self:_retrieve_response(request)
          if ok then
            once_complete("success", res)
          else
            once_complete(
              "failed",
              "unable to retrieve response from temp file"
            )
          end
        end)
      end
    end)
  )

  request:_set_process(proc)
end
```

---

## User Configuration

Users need to configure the model in their `99` setup since `opencode/claude-sonnet-4-5` doesn't exist. Example:

```lua
{
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")
    _99.setup({
      model = "github-copilot/claude-opus-4.5",  -- or another valid model
      -- ... rest of config
    })
    
    -- Use visual_prompt() instead of visual() to get a prompt input
    vim.keymap.set("v", "<leader>9v", function()
      _99.visual_prompt()
    end)
  end,
}
```

To see available models, run: `opencode models`

---

## File 3: `lua/99/init.lua` (Optional - Auto Cleanup)

### Problem
Temp files accumulate over time and are never cleaned up automatically.

### Solution
Add cleanup on VimLeave and expose cleanup commands. Add these to the `setup()` function:

```lua
-- In the setup() function, after other initialization:

-- Auto cleanup on exit
vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    require("99.utils").cleanup_all()
  end,
})

-- Expose cleanup commands
vim.api.nvim_create_user_command("99Cleanup", function()
  require("99.utils").cleanup_all()
  print("99: Cleaned up temp files")
end, { desc = "Clean up 99 temp files for current session" })

vim.api.nvim_create_user_command("99CleanupAll", function()
  require("99.utils").cleanup_temp_dir()
  print("99: Cleaned up .99-tmp directory")
end, { desc = "Clean up entire .99-tmp directory" })
```

### Alternative: User Config
Users can add cleanup to their own config instead of modifying init.lua:

```lua
{
  "ThePrimeagen/99",
  config = function()
    local _99 = require("99")
    _99.setup({
      model = "github-copilot/claude-opus-4.5",
      -- ... rest of config
    })
    
    -- Auto cleanup on exit
    vim.api.nvim_create_autocmd("VimLeave", {
      callback = function()
        require("99.utils").cleanup_all()
      end,
    })
    
    -- Manual cleanup keymaps
    vim.keymap.set("n", "<leader>9c", function()
      require("99.utils").cleanup_all()
      print("99: Cleaned up temp files")
    end, { desc = "Clean up 99 temp files" })
  end,
}
```

---

## Summary of Changes

| File | Change | Purpose |
|------|--------|---------|
| `lua/99/utils.lua` | Use `.99-tmp/` in project directory | Windows path compatibility |
| `lua/99/utils.lua` | Add `cleanup_file()`, `cleanup_all()`, `cleanup_temp_dir()` | Temp file cleanup |
| `lua/99/providers.lua` | Add `OpenCodeProvider:make_request()` override | Capture stdout, strip markdown fences, write to temp file |
| `lua/99/init.lua` | Add VimLeave autocmd and user commands (optional) | Auto cleanup on exit |

---

## Testing

1. Open Neovim in a project directory
2. Select some code in visual mode
3. Press `<leader>9v` (or your configured keymap)
4. Enter a prompt describing what you want done
5. The selected code should be replaced with the LLM's response

## Known Limitations

- The markdown fence stripping is basic and only handles the first code block
- If `opencode run` outputs multiple code blocks, only the first will be extracted
- These are local patches; updating the plugin via `:Lazy update` will overwrite them
