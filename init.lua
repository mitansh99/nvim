-- ============================================================================
--  Neovim config  —  minimal, VS Code-flavoured, leader-driven
--
--  Leader key is <Space>. Press <Space> in normal mode and WAIT — a popup
--  menu appears showing every key you can press next. You never have to
--  memorise anything; the menu teaches you.
--
--  Full key list:  :Cheatsheet     (or open ~/.config/nvim/CHEATSHEET.md)
--  Plugin manager: :Lazy
--  LSP / tools:    :Mason
--  Health check:   :checkhealth
-- ============================================================================

-- Leader must be set BEFORE plugins load, or mappings bind to the wrong key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")

-- ---------------------------------------------------------------------------
-- Bootstrap lazy.nvim (the plugin manager). Clones itself on first launch.
-- ---------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
}, {
  ui = { border = "rounded" },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },          -- don't nag about plugin updates
  rocks = { enabled = false },           -- no plugin here needs luarocks, and
                                         -- leaving it on makes :checkhealth
                                         -- report a permanent ERROR
  change_detection = { notify = false },  -- don't nag when you edit this config
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "zipPlugin", "tutor" },
    },
  },
})

-- Apply the saved colour theme (<leader>ut cycles between the three installed).
require("core.theme").load()

-- Keymaps and autocmds load AFTER plugins so every command they reference exists.
require("core.keymaps")
require("core.autocmds")
