-- Ollama Git Commit Message Generator
-- Cross-platform (Windows + Linux) plugin using Ollama HTTP API
-- Usage: require('misc.ollama-commit').commit()

local M = {}

-- Configuration
M.config = {
  default_model = nil, -- Will prompt on first use, then remember
  ollama_host = "http://localhost:11434",
  num_suggestions = 3,
  prompt_template = [[You are a helpful assistant that generates git commit messages.
Based on the following git diff, generate exactly 3 different commit message options.
Follow conventional commits format when appropriate (feat:, fix:, docs:, refactor:, chore:, test:, style:).
Keep messages concise (under 72 characters for the subject line).
Do not include any explanation or extra text.

Output ONLY the 3 commit messages, one per line, numbered like:
1. message one
2. message two
3. message three

Git diff:
%s]],
}

-- State
local state = {
  current_model = nil,
  available_models = nil,
}

--- Notify helper
---@param msg string
---@param level? number
local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Ollama Commit" })
  end)
end

--- Check if we're in a git repository
---@return boolean
local function is_git_repo()
  local result = vim.system({ 'git', 'rev-parse', '--git-dir' }, { text = true }):wait()
  return result.code == 0
end

--- Get available Ollama models via HTTP API
---@param callback fun(models: string[]|nil, err: string|nil)
local function get_models_async(callback)
  local url = M.config.ollama_host .. "/api/tags"

  vim.system({ 'curl', '-s', url }, { text = true }, function(result)
    if result.code ~= 0 then
      callback(nil, "Failed to connect to Ollama. Is it running?")
      return
    end

    local ok, data = pcall(vim.json.decode, result.stdout)
    if not ok or not data or not data.models then
      callback(nil, "Failed to parse Ollama response")
      return
    end

    local models = {}
    for _, model in ipairs(data.models) do
      table.insert(models, model.name)
    end

    state.available_models = models
    callback(models, nil)
  end)
end

--- Get git diff (staged first, fallback to unstaged)
---@return string|nil diff
---@return string|nil error
local function get_git_diff()
  -- Try staged changes first
  local result = vim.system({ 'git', 'diff', '--staged' }, { text = true }):wait()
  if result.code == 0 and result.stdout and #result.stdout > 0 then
    return result.stdout, nil
  end

  -- Fall back to unstaged changes
  result = vim.system({ 'git', 'diff' }, { text = true }):wait()
  if result.code == 0 and result.stdout and #result.stdout > 0 then
    return result.stdout, nil
  end

  return nil, "No changes to commit (no staged or unstaged changes)"
end

--- Call Ollama API to generate commit messages
---@param model string
---@param diff string
---@param callback fun(messages: string[]|nil, err: string|nil)
local function generate_messages_async(model, diff, callback)
  local url = M.config.ollama_host .. "/api/generate"
  local prompt = string.format(M.config.prompt_template, diff)

  local payload = vim.json.encode({
    model = model,
    prompt = prompt,
    stream = false,
  })

  -- Write payload to temp file to avoid shell escaping issues
  local temp_file = vim.fn.tempname()
  local f = io.open(temp_file, 'w')
  if not f then
    callback(nil, "Failed to create temp file")
    return
  end
  f:write(payload)
  f:close()

  notify("Generating commit messages with " .. model .. "...")

  vim.system(
    { 'curl', '-s', '-X', 'POST', url, '-H', 'Content-Type: application/json', '-d', '@' .. temp_file },
    { text = true },
    function(result)
      -- Clean up temp file
      os.remove(temp_file)

      if result.code ~= 0 then
        callback(nil, "Failed to call Ollama API")
        return
      end

      local ok, data = pcall(vim.json.decode, result.stdout)
      if not ok or not data then
        callback(nil, "Failed to parse Ollama response")
        return
      end

      if data.error then
        callback(nil, "Ollama error: " .. data.error)
        return
      end

      if not data.response then
        callback(nil, "Empty response from Ollama")
        return
      end

      -- Parse the 3 commit messages from response
      local messages = {}
      for line in data.response:gmatch("[^\r\n]+") do
        -- Remove leading number and punctuation (e.g., "1. ", "1) ", "1: ")
        local msg = line:match("^%d+[%.%)%:%s]+(.+)$")
        if msg then
          -- Clean up the message
          msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
          if #msg > 0 then
            table.insert(messages, msg)
          end
        end
      end

      if #messages == 0 then
        -- Fallback: try to use non-empty lines as messages
        for line in data.response:gmatch("[^\r\n]+") do
          line = line:gsub("^%s+", ""):gsub("%s+$", "")
          if #line > 0 and #messages < M.config.num_suggestions then
            table.insert(messages, line)
          end
        end
      end

      if #messages == 0 then
        callback(nil, "Could not parse commit messages from response:\n" .. data.response)
        return
      end

      callback(messages, nil)
    end
  )
end

--- Copy message to clipboard
---@param msg string
local function copy_to_clipboard(msg)
  vim.fn.setreg('+', msg)
  vim.fn.setreg('"', msg)
  notify("Copied to clipboard: " .. msg)
end

--- Run git commit with message
---@param msg string
local function run_git_commit(msg)
  vim.system({ 'git', 'commit', '-m', msg }, { text = true }, function(result)
    if result.code == 0 then
      notify("Committed: " .. msg, vim.log.levels.INFO)
    else
      local err = result.stderr or result.stdout or "Unknown error"
      notify("Commit failed: " .. err, vim.log.levels.ERROR)
    end
  end)
end

--- Show commit message picker with Snacks
---@param messages string[]
local function show_message_picker(messages)
  vim.schedule(function()
    -- Build items for picker
    local items = {}
    for i, msg in ipairs(messages) do
      table.insert(items, {
        idx = i,
        text = msg,
        msg = msg,
      })
    end

    -- Try Snacks picker first
    local ok, picker = pcall(require, 'snacks.picker')
    if ok and picker and picker.pick then
      picker.pick({
        source = "select",
        items = items,
        prompt = "Select Commit Message",
        format = function(item)
          return { { item.idx .. ". ", "DiagnosticInfo" }, { item.msg } }
        end,
        confirm = function(p, item)
          if item then
            p:close()
            -- Show action picker
            vim.ui.select(
              { "[c] Copy to clipboard", "[C] Copy + Commit" },
              { prompt = "Action:" },
              function(choice)
                if choice then
                  copy_to_clipboard(item.msg)
                  if choice:match("^%[C%]") then
                    run_git_commit(item.msg)
                  end
                end
              end
            )
          end
        end,
        actions = {
          copy = function(p, item)
            if item then
              p:close()
              copy_to_clipboard(item.msg)
            end
          end,
          commit = function(p, item)
            if item then
              p:close()
              copy_to_clipboard(item.msg)
              run_git_commit(item.msg)
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["c"] = { "copy", desc = "Copy to clipboard", mode = { "n", "i" } },
              ["C"] = { "commit", desc = "Copy + Commit", mode = { "n", "i" } },
            },
          },
          list = {
            keys = {
              ["c"] = { "copy", desc = "Copy to clipboard", mode = { "n" } },
              ["C"] = { "commit", desc = "Copy + Commit", mode = { "n" } },
            },
          },
        },
      })
    else
      -- Fallback to vim.ui.select
      vim.ui.select(messages, {
        prompt = "Select Commit Message:",
        format_item = function(msg)
          return msg
        end,
      }, function(choice)
        if choice then
          vim.ui.select(
            { "[c] Copy to clipboard", "[C] Copy + Commit" },
            { prompt = "Action:" },
            function(action)
              if action then
                copy_to_clipboard(choice)
                if action:match("^%[C%]") then
                  run_git_commit(choice)
                end
              end
            end
          )
        end
      end)
    end
  end)
end

--- Show model picker
---@param models string[]
---@param callback fun(model: string|nil)
local function show_model_picker(models, callback)
  vim.schedule(function()
    local ok, picker = pcall(require, 'snacks.picker')
    if ok and picker and picker.pick then
      local items = {}
      for _, model in ipairs(models) do
        table.insert(items, {
          text = model,
          model = model,
        })
      end

      picker.pick({
        source = "select",
        items = items,
        prompt = "Select Ollama Model",
        format = function(item)
          local hl = item.model == state.current_model and "DiagnosticOk" or nil
          local prefix = item.model == state.current_model and "* " or "  "
          return { { prefix .. item.model, hl } }
        end,
        confirm = function(p, item)
          if item then
            p:close()
            state.current_model = item.model
            M.config.default_model = item.model
            callback(item.model)
          else
            callback(nil)
          end
        end,
      })
    else
      -- Fallback to vim.ui.select
      vim.ui.select(models, {
        prompt = "Select Ollama Model:",
        format_item = function(model)
          local prefix = model == state.current_model and "* " or "  "
          return prefix .. model
        end,
      }, function(choice)
        if choice then
          state.current_model = choice
          M.config.default_model = choice
        end
        callback(choice)
      end)
    end
  end)
end

--- Public: Select/change Ollama model
function M.select_model()
  get_models_async(function(models, err)
    if err then
      notify(err, vim.log.levels.ERROR)
      return
    end

    if not models or #models == 0 then
      notify("No Ollama models found. Install with: ollama pull <model>", vim.log.levels.WARN)
      return
    end

    show_model_picker(models, function(model)
      if model then
        notify("Default model set to: " .. model)
      end
    end)
  end)
end

--- Public: Main entry point - generate commit messages
function M.commit()
  -- Check if in git repo
  if not is_git_repo() then
    notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  -- Get diff
  local diff, diff_err = get_git_diff()
  if not diff then
    notify(diff_err or "No changes to commit", vim.log.levels.WARN)
    return
  end

  -- Truncate diff if too large (Ollama context limit)
  local max_diff_chars = 8000
  if #diff > max_diff_chars then
    diff = diff:sub(1, max_diff_chars) .. "\n\n[... diff truncated ...]"
    notify("Diff truncated to " .. max_diff_chars .. " chars", vim.log.levels.WARN)
  end

  -- Get models and show picker
  get_models_async(function(models, err)
    if err then
      notify(err, vim.log.levels.ERROR)
      return
    end

    if not models or #models == 0 then
      notify("No Ollama models found. Install with: ollama pull <model>", vim.log.levels.WARN)
      return
    end

    -- Show model picker
    show_model_picker(models, function(model)
      if not model then
        notify("Cancelled", vim.log.levels.INFO)
        return
      end

      -- Generate messages
      generate_messages_async(model, diff, function(messages, gen_err)
        if gen_err then
          notify(gen_err, vim.log.levels.ERROR)
          return
        end

        if not messages or #messages == 0 then
          notify("No commit messages generated", vim.log.levels.WARN)
          return
        end

        show_message_picker(messages)
      end)
    end)
  end)
end

return M
