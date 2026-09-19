-- ============================================================================
--  Editor settings. Every line is one behaviour. Change freely.
--  Look up any option with:  :help 'optionname'
-- ============================================================================

local o = vim.opt

-- Line numbers ---------------------------------------------------------------
o.number = true          -- show a number on the current line
o.relativenumber = true  -- other lines show DISTANCE from cursor (hybrid mode)
                         -- so "5j" jumps 5 down, "3k" jumps 3 up

-- Indentation ----------------------------------------------------------------
o.expandtab = true       -- pressing Tab inserts spaces, not a tab character
o.shiftwidth = 2         -- an indent level is 2 spaces
o.tabstop = 2            -- a literal tab renders 2 columns wide
o.softtabstop = 2
o.smartindent = true     -- guess the indent of a new line from the one above
o.breakindent = true     -- wrapped lines keep the indent of the original

-- Search ---------------------------------------------------------------------
o.ignorecase = true      -- searching "foo" also matches "Foo"
o.smartcase = true       -- ...unless you type a capital, then it's exact
o.hlsearch = true        -- highlight all matches (<Esc> clears the highlight)
o.incsearch = true       -- jump to matches while you're still typing

-- Appearance -----------------------------------------------------------------
o.termguicolors = true   -- 24-bit colour, required by modern themes
o.cursorline = true      -- faint highlight on the line you're on
o.signcolumn = "yes"     -- always reserve the gutter so text doesn't jump
o.wrap = false           -- long lines run off-screen instead of wrapping
o.scrolloff = 8          -- keep 8 lines visible above/below the cursor
o.sidescrolloff = 8
o.showmode = false       -- the statusline already shows the mode
o.pumheight = 12         -- max height of the autocomplete popup
o.winborder = "rounded"  -- rounded borders on floating windows (Neovim 0.11+)
o.fillchars = { eob = " " }  -- hide the "~" on empty lines below the buffer

-- Splits ---------------------------------------------------------------------
o.splitright = true      -- vertical splits open to the RIGHT (like VS Code)
o.splitbelow = true      -- horizontal splits open BELOW

-- Files & undo ---------------------------------------------------------------
o.undofile = true        -- undo history survives closing the file
o.swapfile = false       -- no .swp clutter
o.backup = false
o.updatetime = 250       -- faster git signs / hover hints (ms)
o.timeoutlen = 400       -- how long to wait for the which-key popup (ms)
o.confirm = true         -- ask to save instead of refusing to quit

-- System clipboard -----------------------------------------------------------
-- Yank (y) and paste (p) use the macOS clipboard, so Cmd+V works elsewhere.
-- Scheduled so it doesn't slow down startup.
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

-- Mouse ----------------------------------------------------------------------
o.mouse = "a"            -- click, drag-select and scroll all work
o.mousemoveevent = true  -- needed for hovering over bufferline tabs

-- Unused language providers ---------------------------------------------------
-- Neovim can host plugins written in Perl/Ruby/Python/Node. You use none of
-- them, so turning these off removes the :checkhealth warnings and shaves a
-- little startup time.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0

-- Diagnostics (the red/yellow squiggles from the language server) -------------
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
      [vim.diagnostic.severity.HINT]  = " ",
    },
  },
})
