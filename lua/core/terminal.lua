-- ============================================================================
--  Terminal that opens INSIDE the code area.
--
--  toggleterm's horizontal split uses `botright`, which always spans the full
--  window width - so it sits underneath the file tree too and squashes it.
--  A plain `:split` of the code window stays inside that column instead, which
--  is what VS Code's panel does.
--
--  The shell persists between toggles: hiding the window keeps the buffer, so
--  `npm run dev` keeps running.
-- ============================================================================

local M = {}

-- One entry per direction, so a bottom and a side terminal can coexist.
local terms = {
  horizontal = { buf = nil, win = nil },
  vertical   = { buf = nil, win = nil },
}

local SIDE_PANEL_FILETYPES = { ["neo-tree"] = true, ["gitpanel"] = true }

local function is_side_panel(win)
  local buf = vim.api.nvim_win_get_buf(win)
  return SIDE_PANEL_FILETYPES[vim.bo[buf].filetype] == true
end

local function is_terminal(win)
  return vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal"
end

--- The window the terminal should split. Never the file tree, never another
--- terminal - otherwise the split lands in the sidebar column.
local function code_window()
  local cur = vim.api.nvim_get_current_win()
  if not is_side_panel(cur) and not is_terminal(cur) then
    return cur
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not is_side_panel(win) and not is_terminal(win) then
      return win
    end
  end
  return cur   -- nothing else open; split whatever we're in
end

--- @param direction "horizontal"|"vertical"
function M.toggle(direction)
  direction = direction or "horizontal"
  local t = terms[direction]

  -- Visible? Hide it. The buffer stays alive, so the shell keeps running.
  if t.win and vim.api.nvim_win_is_valid(t.win) then
    vim.api.nvim_win_close(t.win, false)
    t.win = nil
    return
  end

  local target = code_window()
  vim.api.nvim_set_current_win(target)

  if direction == "vertical" then
    local avail = vim.api.nvim_win_get_width(target)
    -- 40% of the code column, but never so wide that the code is unusable:
    -- a plain max(40, ...) squashed the editor to 4 columns on a narrow window.
    local width = math.floor(avail * 0.4)
    width = math.max(width, math.min(40, avail - 20))
    width = math.min(width, math.max(20, avail - 20))
    vim.cmd("rightbelow vsplit")
    vim.api.nvim_win_set_width(0, width)
  else
    vim.cmd("rightbelow split")
    vim.api.nvim_win_set_height(0, 15)
  end
  t.win = vim.api.nvim_get_current_win()

  if t.buf and vim.api.nvim_buf_is_valid(t.buf) then
    vim.api.nvim_win_set_buf(t.win, t.buf)          -- reuse the running shell
  else
    vim.cmd("terminal")
    t.buf = vim.api.nvim_get_current_buf()
    vim.bo[t.buf].buflisted = false                 -- keep it out of the tab bar
  end

  -- Don't let the terminal get resized away when other splits change.
  vim.wo[t.win].winfixheight = direction == "horizontal"
  vim.wo[t.win].winfixwidth = direction == "vertical"

  vim.cmd("startinsert")
end

--- Hide whichever terminal is focused. Bound to Ctrl+\ so it works from
--- inside the terminal, where Space would just type a space into the shell.
function M.hide_current()
  local cur = vim.api.nvim_get_current_win()
  for _, t in pairs(terms) do
    if t.win == cur then
      vim.api.nvim_win_close(t.win, false)
      t.win = nil
      return
    end
  end
  M.toggle("horizontal")   -- not in a terminal: open the bottom one
end

return M
