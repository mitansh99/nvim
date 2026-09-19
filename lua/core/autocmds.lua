-- ============================================================================
--  Autocommands — things Neovim does automatically on certain events.
-- ============================================================================

local augroup = function(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Briefly highlight text you just yanked, so you can see what was copied.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})

-- Reopen a file with the cursor where you left it.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Press "q" to close throwaway windows (help, quickfix, git output...).
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("quick_close"),
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Terminals: no line numbers, start typing immediately.
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
})

-- Reload a file if it changed on disk (e.g. after a git checkout).
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Create missing parent directories when you save a new file.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("mkdir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Markdown is prose, not code: wrap long lines at the window edge instead of
-- letting them run off-screen. j/k are remapped to move by VISUAL line so a
-- wrapped paragraph navigates the way you'd expect. Code files are unaffected.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("prose"),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function(event)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true    -- break between words, not mid-word
    vim.opt_local.breakindent = true  -- wrapped lines keep the list indent
    for _, key in ipairs({ "j", "k" }) do
      vim.keymap.set("n", key, "g" .. key, { buffer = event.buf, silent = true })
    end
    vim.keymap.set("n", "<Down>", "gj", { buffer = event.buf, silent = true })
    vim.keymap.set("n", "<Up>", "gk", { buffer = event.buf, silent = true })
  end,
})

-- Remember closed files so <leader>bu can reopen them.
vim.api.nvim_create_autocmd("BufDelete", {
  group = augroup("track_closed"),
  callback = function(event)
    require("core.buffers").remember_closed(event.buf)
  end,
})

-- :Cheatsheet — open the key reference in a split.
vim.api.nvim_create_user_command("Cheatsheet", function()
  vim.cmd("vsplit " .. vim.fn.stdpath("config") .. "/CHEATSHEET.md")
end, { desc = "Open the keybinding cheatsheet" })
