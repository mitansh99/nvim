-- ============================================================================
--  Window helpers.
-- ============================================================================

local M = {}

-- Remembers the layout from before a zoom so it can be put back exactly.
local saved_layout = nil

--- Blow the current pane up to fill the screen, or restore the previous
--- layout if already zoomed. Like VS Code's Ctrl+K Z.
function M.toggle_zoom()
  if saved_layout then
    -- winrestcmd() returns a plain ex command that resizes every window back.
    local ok = pcall(vim.cmd, saved_layout)
    saved_layout = nil
    if not ok then
      vim.cmd("wincmd =") -- layout changed while zoomed; fall back to equalising
    end
    return
  end

  if #vim.api.nvim_list_wins() < 2 then
    vim.notify("Only one pane open.", vim.log.levels.INFO)
    return
  end

  saved_layout = vim.fn.winrestcmd()
  vim.cmd("wincmd _") -- maximum height
  vim.cmd("wincmd |") -- maximum width
end

return M
