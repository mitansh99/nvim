-- ============================================================================
--  EVERY keybinding lives in this file. Nothing is hidden anywhere else.
--
--  <leader> is the SPACE bar. Press Space and wait — a menu shows your options.
--  Each mapping below names the VS Code key it replaces.
-- ============================================================================

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true, noremap = true })
end

-- ---------------------------------------------------------------------------
-- TOP LEVEL — the handful you'll press all day
-- ---------------------------------------------------------------------------
map("n", "<leader>s", "<cmd>write<cr>",                      "Save file            (VS Code: Ctrl+S)")
map("n", "<leader>S", "<cmd>wall<cr>",                       "Save all files       (VS Code: Ctrl+K S)")
map("n", "<leader>e", function()
  vim.cmd("Neotree toggle")
  -- neo-tree opens asynchronously; let its window exist before we hang the
  -- commit panel underneath it.
  vim.defer_fn(function() require("core.gitpanel").sync() end, 80)
end, "Toggle file tree     (VS Code: Ctrl+B)")
map("n", "<leader>gl", function() require("core.gitpanel").sync() end, "Toggle the commit panel")
map("n", "<leader>p", "<cmd>Telescope find_files<cr>",       "Find file            (VS Code: Ctrl+P)")
map("n", "<leader>P", "<cmd>Telescope commands<cr>",         "Command palette      (VS Code: Ctrl+Shift+P)")
map("n", "<leader>t", function() require("core.terminal").toggle("horizontal") end,
                                                                 "Terminal below       (VS Code: Ctrl+`)")
map("n", "<leader>T", function() require("core.terminal").toggle("vertical") end,
                                                                 "Terminal beside the code")
map("n", "<leader>q", function() require("core.buffers").close() end, "Close this file      (VS Code: Ctrl+W)")
map("n", "<leader>Q", "<cmd>qall<cr>",                       "Quit Neovim")
map("n", "<leader>x", "<cmd>Telescope diagnostics<cr>",      "List all problems    (VS Code: Ctrl+Shift+M)")

-- Comment toggle. Neovim ships commenting built in as "gc" / "gcc".
-- remap = true is required here, because gcc is itself a mapping and our
-- own map() helper sets noremap, which would stop it resolving.
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, silent = true, desc = "Toggle comment       (VS Code: Ctrl+/)" })
vim.keymap.set("x", "<leader>/", "gc",  { remap = true, silent = true, desc = "Toggle comment       (VS Code: Ctrl+/)" })

-- ---------------------------------------------------------------------------
-- <leader>f — FIND (Telescope: fuzzy search over anything)
-- ---------------------------------------------------------------------------
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",             "Files by name        (VS Code: Ctrl+P)")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",              "Text in project      (VS Code: Ctrl+Shift+F)")
map("n", "<leader>fw", "<cmd>Telescope grep_string<cr>",            "Word under cursor")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",                "Open files")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>",               "Recent files         (VS Code: Ctrl+R)")
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",   "Symbols in file      (VS Code: Ctrl+Shift+O)")
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>",              "Neovim help")
map("n", "<leader>fk", "<cmd>Telescope keymaps<cr>",                "Search all keybinds")
map("n", "<leader>fc", "<cmd>Telescope find_files cwd=~/.config/nvim<cr>", "Edit this config")
map("n", "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>",     "Search in this file  (VS Code: Ctrl+F)")
map("n", "<leader>fR", "<cmd>GrugFar<cr>",                          "Find AND replace across project")
map("n", "<leader>ft", "<cmd>TodoTelescope<cr>",                    "TODO / FIXME comments")

-- ---------------------------------------------------------------------------
-- <leader>c — CODE (language server actions)
-- ---------------------------------------------------------------------------
map("n", "<leader>ca", vim.lsp.buf.code_action,                  "Quick fix            (VS Code: Ctrl+.)")
map("n", "<leader>cr", vim.lsp.buf.rename,                       "Rename symbol        (VS Code: F2)")
map("n", "<leader>ch", vim.lsp.buf.hover,                        "Show docs            (VS Code: hover)")
map("n", "<leader>cd", vim.diagnostic.open_float,                "Explain this error")
map("n", "<leader>cD", "<cmd>Telescope lsp_definitions<cr>",     "Go to definition     (VS Code: F12)")
map("n", "<leader>cR", "<cmd>Telescope lsp_references<cr>",      "Find all references  (VS Code: Shift+F12)")
map("n", "<leader>ci", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation")
map("n", "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
                                                                 "Format file          (VS Code: Shift+Alt+F)")

-- ---------------------------------------------------------------------------
-- <leader>g — GIT
-- ---------------------------------------------------------------------------
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>",           "Who wrote this line")
map("n", "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle inline blame")
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>",         "Preview this change")
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>",           "Stage / unstage this change")
-- gitsigns deprecated undo_stage_hunk (actions.lua:434) and it no longer
-- unstages; stage_hunk now TOGGLES, so it both stages and unstages.
map("n", "<leader>gu", "<cmd>Gitsigns stage_hunk<cr>",           "Unstage this change (toggle)")
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>",           "Discard this change")
map("n", "<leader>gR", function()
  if vim.fn.confirm("Discard ALL unsaved and uncommitted changes in this file?", "&Yes\n&No", 2) == 1 then
    require("gitsigns").reset_buffer()
    vim.cmd("write")
  end
end, "Discard every change in this file")
-- Select lines first to discard or stage only those.
map("x", "<leader>gr", ":Gitsigns reset_hunk<cr>",               "Discard the selected lines")
map("x", "<leader>gs", ":Gitsigns stage_hunk<cr>",               "Stage the selected lines")
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>",             "Diff this file")
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>",         "Browse commits")
map("n", "<leader>gf", "<cmd>Telescope git_status<cr>",          "Changed files")
map("n", "<leader>gg", "<cmd>LazyGit<cr>",                        "Open lazygit (full git UI)")
map("n", "<leader>gv", "<cmd>DiffviewOpen<cr>",                  "Diff view: all changes")
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",         "History of this file")
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>",           "History of the whole repo")
map("n", "<leader>gx", "<cmd>DiffviewClose<cr>",                 "Close the diff view")
map("n", "]g",         "<cmd>Gitsigns next_hunk<cr>",            "Next change")
map("n", "[g",         "<cmd>Gitsigns prev_hunk<cr>",            "Previous change")

-- ---------------------------------------------------------------------------
-- <leader>b — BUFFERS (your open files, shown as tabs along the top)
-- ---------------------------------------------------------------------------
map("n", "<leader>bn", "<cmd>BufferLineCycleNext<cr>",           "Next file            (VS Code: Ctrl+Tab)")
map("n", "<leader>bp", "<cmd>BufferLineCyclePrev<cr>",           "Previous file")
map("n", "<leader>bd", function() require("core.buffers").close() end,       "Close this file")
map("n", "<leader>bD", function() require("core.buffers").close(true) end,   "Close file, discard changes")
map("n", "<leader>bo", function() require("core.buffers").close_others() end, "Close all others")
map("n", "<leader>bl", "<cmd>Telescope buffers<cr>",             "List open files")
map("n", "<leader>bb", "<cmd>BufferLinePick<cr>",                "Pick file by letter")
map("n", "<leader>bu", function() require("core.buffers").reopen_last() end,
                                                                 "Reopen closed file   (VS Code: Ctrl+Shift+T)")
map("n", "<leader>bH", function() require("core.buffers").close_direction("left") end,
                                                                 "Close all tabs to the left")
map("n", "<leader>bL", function() require("core.buffers").close_direction("right") end,
                                                                 "Close all tabs to the right")
-- Quick cycle without the menu:
map("n", "<S-l>",      "<cmd>BufferLineCycleNext<cr>",           "Next file")
map("n", "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",           "Previous file")

-- Jump straight to a tab by position, like VS Code's Cmd+1 .. Cmd+9.
-- 1-8 are absolute positions; 9 jumps to the LAST tab, matching VS Code.
--
-- NOTE: this calls bufferline's Lua API rather than :BufferLineGoToBuffer.
-- The ex command does not pass `absolute`, so ":BufferLineGoToBuffer 1" lands
-- on the wrong tab; go_to(n, true) counts tab positions the way you'd expect.
for i = 1, 8 do
  map("n", "<leader>" .. i, function() require("bufferline").go_to(i, true) end, "Go to file " .. i)
end
map("n", "<leader>9", function() require("bufferline").go_to(-1, true) end, "Go to last file")

-- ---------------------------------------------------------------------------
-- <leader>w — WINDOWS (side-by-side panes)
-- ---------------------------------------------------------------------------
map("n", "<leader>wv", "<cmd>vsplit<cr>",  "Split right          (VS Code: Ctrl+\\)")
map("n", "<leader>ws", "<cmd>split<cr>",   "Split below")
map("n", "<leader>wc", "<cmd>close<cr>",   "Close this pane")
map("n", "<leader>wo", "<cmd>only<cr>",    "Close other panes")
map("n", "<leader>wh", "<C-w>h",           "Focus pane left")
map("n", "<leader>wj", "<C-w>j",           "Focus pane down")
map("n", "<leader>wk", "<C-w>k",           "Focus pane up")
map("n", "<leader>wl", "<C-w>l",           "Focus pane right")
map("n", "<leader>w=", "<C-w>=",           "Equalise pane sizes")
map("n", "<leader>wm", function() require("core.windows").toggle_zoom() end,
                                           "Maximise / restore pane (VS Code: Ctrl+K Z)")
-- Resize with the arrow keys. Repeat by holding the arrow down.
map("n", "<leader>w<Left>",  "<cmd>vertical resize -5<cr>", "Pane narrower")
map("n", "<leader>w<Right>", "<cmd>vertical resize +5<cr>", "Pane wider")
map("n", "<leader>w<Up>",    "<cmd>resize +3<cr>",          "Pane taller")
map("n", "<leader>w<Down>",  "<cmd>resize -3<cr>",          "Pane shorter")

-- ---------------------------------------------------------------------------
-- <leader>u — UI TOGGLES
-- ---------------------------------------------------------------------------
map("n", "<leader>ut", function() require("core.theme").picker() end, "Switch colour theme (live preview)")
map("n", "<leader>uf", function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify("Format on save: " .. (vim.g.format_on_save and "ON" or "OFF"))
end, "Toggle format on save")
map("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end,     "Toggle line wrap")
map("n", "<leader>un", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, "Toggle relative numbers")
map("n", "<leader>ud", function()
  local on = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not on)
  vim.notify("Diagnostics: " .. (on and "OFF" or "ON"))
end, "Toggle error squiggles")
map("n", "<leader>uc", "<cmd>ColorizerToggle<cr>", "Toggle colour swatches")
map("n", "<leader>ui", function()
  local on = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not on, { bufnr = 0 })
  vim.notify("Inlay hints: " .. (on and "OFF" or "ON"))
end, "Toggle inlay hints")
map("n", "<leader>um", "<cmd>RenderMarkdown toggle<cr>", "Toggle markdown rendering")
map("n", "<leader>ul", "<cmd>Lazy<cr>",   "Plugin manager")
map("n", "<leader>uM", "<cmd>Mason<cr>",  "Language server manager")
map("n", "<leader>u?", "<cmd>Cheatsheet<cr>", "Open cheatsheet")

-- ---------------------------------------------------------------------------
-- NON-LEADER KEYS
-- A few vim-standard keys with no sensible leader equivalent. Learn these five
-- and you're fluent; everything else is on the Space menu.
-- ---------------------------------------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<cr>", "Clear search highlight")

-- Jump around code (vim-standard, same idea as VS Code's F12 / hover)
map("n", "gd", vim.lsp.buf.definition,   "Go to definition")
map("n", "gr", "<cmd>Telescope lsp_references<cr>", "Find references")
map("n", "K",  vim.lsp.buf.hover,        "Show docs for symbol under cursor")

-- Jump between errors
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end,  "Next problem         (VS Code: F8)")
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous problem")

-- Move between panes without the menu (matches most terminal muscle memory)
map("n", "<C-h>", "<C-w>h", "Focus pane left")
map("n", "<C-j>", "<C-w>j", "Focus pane down")
map("n", "<C-k>", "<C-w>k", "Focus pane up")
map("n", "<C-l>", "<C-w>l", "Focus pane right")

-- Keep the cursor centred when jumping, so you never lose your place
map("n", "<C-d>", "<C-d>zz", "Half page down")
map("n", "<C-u>", "<C-u>zz", "Half page up")
map("n", "n",     "nzzzv",   "Next search match")
map("n", "N",     "Nzzzv",   "Previous search match")

-- ---------------------------------------------------------------------------
-- VISUAL MODE (after selecting text with v / V / mouse drag)
-- ---------------------------------------------------------------------------
map("v", "<", "<gv", "Indent left, keep selection")
map("v", ">", ">gv", "Indent right, keep selection")
map("v", "J", ":m '>+1<cr>gv=gv", "Move selection down  (VS Code: Alt+Down)")
map("v", "K", ":m '<-2<cr>gv=gv", "Move selection up    (VS Code: Alt+Up)")
map("v", "p", '"_dP', "Paste without clobbering your clipboard")

-- ---------------------------------------------------------------------------
-- TERMINAL MODE
-- ---------------------------------------------------------------------------
map("n", "<C-\\>", function() require("core.terminal").hide_current() end, "Toggle terminal")
map("t", "<C-\\>", function()
  vim.cmd("stopinsert")
  require("core.terminal").hide_current()
end, "Hide terminal from inside it")
map("t", "<Esc><Esc>", "<C-\\><C-n>", "Leave terminal insert mode")

-- Jump straight from the terminal to a code window, without leaving insert
-- mode first. This takes four keys away from the shell running inside it:
--   Ctrl+h  was backspace            -> plain Backspace still works
--   Ctrl+j  was another Enter        -> plain Enter still works
--   Ctrl+k  was kill-to-end-of-line  -> no replacement; use Ctrl+u to clear the
--                                       whole line, or End then Backspace
--   Ctrl+l  was clear screen         -> type `clear`, or Cmd+K in Ghostty
-- Ctrl+w (delete previous word) is NOT rebound and still works.
-- Ctrl+\ toggles the terminal away entirely.
map("t", "<C-h>", "<C-\\><C-n><C-w>h", "Focus pane left from terminal")
map("t", "<C-j>", "<C-\\><C-n><C-w>j", "Focus pane down from terminal")
map("t", "<C-k>", "<C-\\><C-n><C-w>k", "Focus pane up from terminal")
map("t", "<C-l>", "<C-\\><C-n><C-w>l", "Focus pane right from terminal")
