-- ============================================================================
--  Theme registry and picker.
--
--  <leader>ut opens a searchable list. Moving the cursor applies the theme to
--  your real code straight away, Enter keeps it, Esc puts back what you had.
--  The choice is remembered across restarts.
--
--  To add a theme: install the plugin in lua/plugins/ui.lua, then add one row
--  to M.themes below.
-- ============================================================================

local M = {}

-- Gruvbox ships as a single colorscheme with a `contrast` setting rather than
-- three separate ones, so each variant re-runs setup() before applying.
local function gruvbox(contrast)
  return function()
    require("gruvbox").setup({
      terminal_colors = true,
      transparent_mode = true,
      contrast = contrast,
      italic = { strings = false, comments = true, folds = true },
    })
  end
end

--- key         unique id, used to remember your choice
--- label       what the picker shows
--- colorscheme the actual :colorscheme name
--- before      optional setup to run first
M.themes = {
  -- Sampled from the Zed screenshot. See lua/themes/zedmatch.lua.
  { key = "zedmatch",         label = "Zed Match",         colorscheme = "zedmatch" },
  { key = "zedmatch-solid",   label = "Zed Match (solid)", colorscheme = "zedmatch-solid" },
  { key = "catppuccin-mocha", label = "Catppuccin Mocha",  colorscheme = "catppuccin-mocha" },
  { key = "tokyonight-night", label = "Tokyo Night",       colorscheme = "tokyonight-night" },
  { key = "onedark",          label = "One Dark",          colorscheme = "onedark" },
  { key = "ayu-dark",         label = "Ayu Dark",          colorscheme = "ayu-dark" },
  { key = "ayu-mirage",       label = "Ayu Mirage",        colorscheme = "ayu-mirage" },
  { key = "gruvbox",          label = "Gruvbox Dark",      colorscheme = "gruvbox", before = gruvbox("") },
  { key = "gruvbox-hard",     label = "Gruvbox Dark Hard", colorscheme = "gruvbox", before = gruvbox("hard") },
  { key = "gruvbox-soft",     label = "Gruvbox Dark Soft", colorscheme = "gruvbox", before = gruvbox("soft") },
  { key = "nord",             label = "Nord",              colorscheme = "nord" },
}

local state_file = vim.fn.stdpath("state") .. "/theme.txt"

local function by_key(key)
  for _, theme in ipairs(M.themes) do
    if theme.key == key then
      return theme
    end
  end
end

--- Apply a theme without remembering it (used for live preview).
function M.apply(theme)
  if theme.before then
    theme.before()
  end
  local ok, err = pcall(vim.cmd.colorscheme, theme.colorscheme)
  if not ok then
    vim.notify("Theme '" .. theme.label .. "' failed: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  M.current = theme.key
  return true
end

--- Apply a theme AND remember it for next time.
function M.set(key)
  local theme = by_key(key)
  if not theme then
    return
  end
  if M.apply(theme) then
    pcall(vim.fn.writefile, { key }, state_file)
  end
end

--- Restore the saved theme. Called at startup and when a preview is cancelled.
function M.load()
  local ok, saved = pcall(vim.fn.readfile, state_file)
  local theme = (ok and saved[1] and by_key(saved[1])) or M.themes[1]
  M.apply(theme)
end

-- ---------------------------------------------------------------------------
-- The picker
-- ---------------------------------------------------------------------------

function M.picker()
  local ok, pickers = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("Telescope isn't available.", vim.log.levels.ERROR)
    return
  end
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local committed = false

  local picker = pickers.new({
    layout_strategy = "vertical",
    layout_config = { width = 0.4, height = 0.5, prompt_position = "top" },
  }, {
    prompt_title = "Select Theme",
    finder = finders.new_table({
      results = M.themes,
      entry_maker = function(theme)
        return { value = theme, display = theme.label, ordinal = theme.label }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if not selection then
          return
        end
        committed = true
        actions.close(prompt_bufnr)
        M.set(selection.value.key)
        vim.notify("Theme: " .. selection.value.label)
      end)
      return true
    end,
  })

  -- Preview live as the highlight moves, the way Zed's theme selector does.
  local set_selection = picker.set_selection
  picker.set_selection = function(self, row)
    set_selection(self, row)
    local selection = action_state.get_selected_entry()
    if selection then
      M.apply(selection.value)
    end
  end

  -- Put the old theme back if you press Esc instead of Enter.
  local close_windows = picker.close_windows
  picker.close_windows = function(status)
    close_windows(status)
    if not committed then
      M.load()
    end
  end

  picker:find()
end

return M
