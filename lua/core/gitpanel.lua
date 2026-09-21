-- ============================================================================
--  Recent commits, in a panel under the file tree.
--
--  Opens and closes together with the tree (<leader>e).
--  Inside the panel:  <CR> open the commit's diff   r refresh   q close
-- ============================================================================

local M = {}

local state = { buf = nil, win = nil, hashes = {} }
local NS = vim.api.nvim_create_namespace("gitpanel")
local COUNT = 30     -- how many commits to fetch
local HEIGHT = 12    -- rows the panel takes from the tree

-- Fallback colours, so the panel is readable on every theme. zedmatch
-- overrides these; `default = true` means a theme's own version wins.
local function set_default_highlights()
  local defaults = {
    GitPanelHead    = { link = "Function" },
    GitPanelGraph   = { link = "Comment" },
    GitPanelSubject = { link = "Normal" },
    GitPanelTime    = { link = "LineNr" },
    GitPanelRef     = { link = "Keyword" },
  }
  for group, spec in pairs(defaults) do
    spec.default = true
    vim.api.nvim_set_hl(0, group, spec)
  end
end

local function repo_root()
  local out = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 or not out[1] or out[1] == "" then
    return nil
  end
  return out[1]
end

--- Shorten "3 hours ago" to "3h" so it fits a 34-column sidebar.
local function short_time(s)
  s = (s or ""):gsub(" ago$", "")
  s = s:gsub("(%d+)%s*seconds?", "%1s"):gsub("(%d+)%s*minutes?", "%1m")
       :gsub("(%d+)%s*hours?", "%1h"):gsub("(%d+)%s*days?", "%1d")
       :gsub("(%d+)%s*weeks?", "%1w"):gsub("(%d+)%s*months?", "%1mo")
       :gsub("(%d+)%s*years?", "%1y")
  return (s:gsub("%s+", ""))
end

--- @return string[] lines, table[] meta
local function collect()
  if not repo_root() then
    return { " not a git repository" }, {}
  end
  -- \1 as separator: it cannot occur in a commit subject.
  local raw = vim.fn.systemlist({
    "git", "log", "--no-color", "-n", tostring(COUNT),
    "--pretty=format:%h\1%s\1%cr\1%D",
  })
  if vim.v.shell_error ~= 0 or #raw == 0 then
    return { " no commits yet" }, {}
  end

  local meta = {}
  for i, entry in ipairs(raw) do
    local hash, subject, when, refs = entry:match("^(.-)\1(.-)\1(.-)\1(.*)$")
    if hash then
      -- Keep only the first ref, and drop the noisy "HEAD -> " prefix.
      local ref = (refs or ""):match("^([^,]+)") or ""
      ref = ref:gsub("HEAD %-> ", ""):gsub("^%s+", ""):gsub("%s+$", "")
      meta[#meta + 1] = {
        hash = hash,
        subject = subject,
        when = short_time(when),
        ref = ref,
        is_head = (i == 1),
      }
    end
  end
  return nil, meta
end

local function render()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return
  end
  local fallback, meta = collect()
  state.hashes = {}

  local width = (state.win and vim.api.nvim_win_is_valid(state.win))
      and vim.api.nvim_win_get_width(state.win) or 34

  local lines, marks = {}, {}
  if fallback then
    lines = fallback
  else
    for i, m in ipairs(meta) do
      state.hashes[i] = m.hash
      local glyph = m.is_head and "●" or "│"
      local label = m.subject
      if m.ref ~= "" then
        label = m.ref .. "  " .. label
      end

      -- Trim the subject so the right-aligned time always fits.
      local room = width - #m.when - 4
      if vim.fn.strdisplaywidth(label) > room then
        label = vim.fn.strcharpart(label, 0, math.max(1, room - 1)) .. "…"
      end
      local left = " " .. glyph .. " " .. label
      local pad = math.max(1, width - vim.fn.strdisplaywidth(left) - #m.when - 1)
      lines[i] = left .. string.rep(" ", pad) .. m.when

      marks[i] = {
        glyph = { 1, 1 + #glyph },                       -- byte range of ● / │
        ref = (m.ref ~= "") and { 2 + #glyph, 2 + #glyph + #m.ref } or nil,
        time = { #lines[i] - #m.when, #lines[i] },
        is_head = m.is_head,
      }
    end
  end

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false

  vim.api.nvim_buf_clear_namespace(state.buf, NS, 0, -1)
  for i, mk in pairs(marks) do
    local row = i - 1
    local function hl(range, group)
      if range then
        pcall(vim.api.nvim_buf_set_extmark, state.buf, NS, row, range[1], {
          end_row = row, end_col = range[2], hl_group = group,
        })
      end
    end
    hl(mk.glyph, mk.is_head and "GitPanelHead" or "GitPanelGraph")
    hl(mk.ref, "GitPanelRef")
    hl(mk.time, "GitPanelTime")
  end
end

--- The neo-tree window, if one is open.
local function tree_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
      return win
    end
  end
end

function M.is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

function M.close()
  if M.is_open() then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

function M.open()
  if M.is_open() then
    render()
    return
  end
  local tree = tree_win()
  if not tree then
    return -- nothing to hang the panel under
  end

  set_default_highlights()

  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].buftype = "nofile"
    vim.bo[state.buf].bufhidden = "hide"
    vim.bo[state.buf].swapfile = false
    vim.bo[state.buf].filetype = "gitpanel"
    vim.api.nvim_buf_set_name(state.buf, "git://commits")

    local function map(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = state.buf, silent = true, desc = desc })
    end
    map("<CR>", function() M.open_commit() end, "Open this commit's diff")
    map("r", function() render() end, "Refresh commits")
    map("q", function() M.close() end, "Close the commit panel")
  end

  -- Split the TREE window, so the panel sits under the sidebar only.
  local prev = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(tree)
  vim.cmd("belowright split")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.api.nvim_win_set_height(state.win, HEIGHT)

  local wo = vim.wo[state.win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.wrap = false
  wo.cursorline = true
  wo.winfixheight = true
  wo.statusline = "  Commits"

  render()
  if vim.api.nvim_win_is_valid(prev) then
    vim.api.nvim_set_current_win(prev)
  end
end

--- Keep the panel in step with the tree: open when the tree is, closed when not.
function M.sync()
  if tree_win() then
    M.open()
  else
    M.close()
  end
end

function M.refresh()
  if M.is_open() then
    render()
  end
end

--- Show the diff for the commit under the cursor.
function M.open_commit()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local hash = state.hashes[row]
  if not hash then
    return
  end
  vim.cmd("DiffviewOpen " .. hash .. "^!")
end

return M
