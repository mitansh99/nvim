-- ============================================================================
--  Buffer helpers.
--
--  Neovim's built-in :bdelete closes the WINDOW along with the buffer when the
--  buffer is showing in a split. VS Code never does that — closing a tab leaves
--  the pane open. These helpers keep your layout intact.
-- ============================================================================

local M = {}

-- Which buffer should the window show once the current one closes?
-- Prefer the next tab to the right, like closing a tab in VS Code; fall back
-- to the one on the left when you're already at the end.
local function pick_replacement(target, others)
  table.sort(others)
  for _, b in ipairs(others) do
    if b > target then
      return b
    end
  end
  return others[#others]
end

--- Close the current buffer without collapsing any window.
--- @param force boolean|nil discard unsaved changes
function M.close(force)
  local target = vim.api.nvim_get_current_buf()

  if vim.bo[target].modified and not force then
    vim.notify(
      "Unsaved changes. Save with <leader>s, or discard with <leader>bD.",
      vim.log.levels.WARN
    )
    return
  end

  local others = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted and b ~= target
  end, vim.api.nvim_list_bufs())

  -- Repoint every window showing this buffer BEFORE deleting it.
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == target then
      local replacement = #others > 0 and pick_replacement(target, others)
        or vim.api.nvim_create_buf(true, false) -- nothing left: fresh empty buffer
      vim.api.nvim_win_set_buf(win, replacement)
    end
  end

  pcall(vim.api.nvim_buf_delete, target, { force = force or false })
end

--- Close every listed buffer except the current one.
function M.close_others()
  local keep = vim.api.nvim_get_current_buf()
  local closed = 0
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buflisted and b ~= keep and not vim.bo[b].modified then
      pcall(vim.api.nvim_buf_delete, b, {})
      closed = closed + 1
    end
  end
  vim.notify("Closed " .. closed .. " file" .. (closed == 1 and "" or "s"))
end

-- ---------------------------------------------------------------------------
-- Reopen-last-closed (VS Code's Ctrl+Shift+T).
-- core/autocmds.lua feeds this on every BufDelete, so it catches files closed
-- any way at all, not just via the mappings above.
-- ---------------------------------------------------------------------------

M.closed_stack = {}

--- Record a buffer as recently closed. Called from the BufDelete autocmd.
function M.remember_closed(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  -- Only real files: skip terminals, help, neo-tree, unnamed scratch buffers.
  if vim.bo[buf].buftype ~= "" then
    return
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or vim.fn.filereadable(name) ~= 1 then
    return
  end

  -- Move to the top if it's already in the stack, rather than duplicating.
  for i = #M.closed_stack, 1, -1 do
    if M.closed_stack[i] == name then
      table.remove(M.closed_stack, i)
    end
  end

  table.insert(M.closed_stack, name)
  if #M.closed_stack > 20 then
    table.remove(M.closed_stack, 1)
  end
end

--- Reopen the most recently closed file.
function M.reopen_last()
  local name = table.remove(M.closed_stack)
  if not name then
    vim.notify("No recently closed files.", vim.log.levels.INFO)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(name))
end

-- ---------------------------------------------------------------------------
-- Close everything to one side of the current tab.
--
-- bufferline ships :BufferLineCloseLeft / :BufferLineCloseRight, but they act
-- on the tabs currently VISIBLE in the tabline. When you have more files open
-- than fit on screen, they silently do nothing. These work off the real tab
-- order instead, so they behave the same whatever the window width.
-- ---------------------------------------------------------------------------

--- The open files in tab order.
---
--- This deliberately uses sorted buffer numbers rather than bufferline's
--- get_elements(). That function only refreshes when the tabline redraws, so
--- right after closing or reopening a file it hands back a stale list and the
--- current buffer isn't in it - which made "close left" silently do nothing.
--- bufferline's default sort is by buffer number, so these agree. (If you ever
--- set a custom `sort_by`, or drag tabs around, this falls back to numeric
--- order rather than the on-screen order.)
local function ordered_buffers()
  local ids = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())
  table.sort(ids)
  return ids
end

--- @param direction "left"|"right"
function M.close_direction(direction)
  local order = ordered_buffers()
  local current = vim.api.nvim_get_current_buf()

  local index
  for i, b in ipairs(order) do
    if b == current then
      index = i
      break
    end
  end
  if not index then
    return
  end

  local from, to = 1, index - 1
  if direction == "right" then
    from, to = index + 1, #order
  end

  local closed, skipped = 0, 0
  for i = from, to do
    local b = order[i]
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted then
      if vim.bo[b].modified then
        skipped = skipped + 1
      else
        pcall(vim.api.nvim_buf_delete, b, {})
        closed = closed + 1
      end
    end
  end

  local msg = "Closed " .. closed .. " file" .. (closed == 1 and "" or "s") .. " to the " .. direction
  if skipped > 0 then
    msg = msg .. " (" .. skipped .. " skipped, unsaved)"
  end
  vim.notify(msg)
end

return M
