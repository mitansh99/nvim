-- ============================================================================
--  EDITOR — fuzzy finder, syntax highlighting, git, terminal, auto-pairs.
-- ============================================================================

return {

  -- --------------------------------------------------------------------------
  -- TELESCOPE — the fuzzy finder behind every <leader>f mapping.
  -- Inside a picker: type to filter, Ctrl+j/k to move, Enter to open,
  -- Ctrl+v to open in a vertical split, Esc Esc to cancel.
  -- --------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        -- Native C sorter: makes filtering instant in big repos like your
        -- diasimos web client (1000+ jsx files).
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            width = 0.9,
            height = 0.85,
          },
          file_ignore_patterns = {
            "node_modules/", "%.git/", "dist/", "build/", "%.next/",
            "ios/Pods/", "android/%.gradle/", "%.lock",
          },
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
              ["<Esc>"] = "close",          -- one Esc closes, like VS Code
            },
          },
        },
        pickers = {
          find_files = { hidden = true },   -- include dotfiles
        },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
        },
      })
      pcall(telescope.load_extension, "fzf")
    end,
  },

  -- --------------------------------------------------------------------------
  -- TREESITTER — real syntax highlighting (parses the code, not regex).
  -- This is what makes JSX props, hooks and Go structs colour correctly.
  -- --------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function(_, opts)
      -- macOS toolchain fix. Xcode.app on this machine is older than the
      -- installed Command Line Tools, so the default compiler + SDK pair is
      -- mismatched and parser linking fails with "unknown architecture
      -- arm64e.x1". bin/ts-cc forces a matched CLT clang + CLT SDK pair.
      -- Scoped to parser builds only; see the comments in bin/ts-cc.
      local shim = vim.fn.stdpath("config") .. "/bin/ts-cc"
      if vim.fn.has("mac") == 1 and vim.fn.executable(shim) == 1 then
        require("nvim-treesitter.install").compilers = { shim }
      end
      require("nvim-treesitter.configs").setup(opts)

      -- ----------------------------------------------------------------
      -- Fix: markdown fenced code blocks break treesitter on Neovim 0.12.
      --
      -- nvim-treesitter's master branch registers this directive with
      -- `all = false`, expecting Neovim to hand it a single node. Neovim
      -- 0.12 passes a LIST of nodes regardless, so the plugin calls
      -- node:range() on a table and throws:
      --
      --   vim/treesitter.lua: attempt to call method 'range' (a nil value)
      --
      -- The error aborts the whole decoration pass, which kills treesitter
      -- highlighting AND render-markdown for any .md file containing a
      -- ```lang fence. Re-registering with `all = true` and unwrapping the
      -- list restores it. Only markdown injections are affected; jsx, html,
      -- go, css and lua were all verified unaffected.
      --
      -- Remove this once nvim-treesitter's main branch is adopted (master
      -- states "Neovim 0.12 is not supported").
      -- ----------------------------------------------------------------
      local aliases = { ex = "elixir", pl = "perl", sh = "bash", uxn = "uxntal", ts = "typescript" }
      vim.treesitter.query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
        local nodes = match[pred[2]]
        -- Neovim >= 0.10 gives a list; older gives a bare node.
        local node = type(nodes) == "table" and nodes[#nodes] or nodes
        if not node then
          return
        end
        local alias = vim.treesitter.get_node_text(node, bufnr):lower()
        metadata["injection.language"] = vim.filetype.match({ filename = "a." .. alias })
          or aliases[alias]
          or alias
      end, { force = true, all = true })
    end,
    opts = {
      ensure_installed = {
        "javascript", "typescript", "tsx",   -- your main stack (JSX is handled by the javascript parser)
        "html", "css", "scss",
        "json", "jsonc", "yaml", "toml",
        "go", "gomod", "gosum",
        "c",
        "lua", "vim", "vimdoc", "query",
        "bash", "markdown", "markdown_inline", "gitignore", "diff",
        "dockerfile", "sql", "regex", "jsdoc",
      },
      auto_install = true,        -- grab a parser automatically for new filetypes
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Keeps the enclosing function/JSX tag pinned to the top of the screen
  -- while you scroll inside it.
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = { max_lines = 3, multiline_threshold = 1 },
  },

  -- --------------------------------------------------------------------------
  -- GIT SIGNS — change markers in the gutter, blame, stage/reset a hunk.
  -- --------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "┃" },
        change       = { text = "┃" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "~" },
        untracked    = { text = "┆" },
      },
      current_line_blame = false,   -- <leader>gB turns inline blame on
      current_line_blame_opts = {
        virt_text_pos = "eol",
        delay = 300,
      },
      current_line_blame_formatter = "  <author>, <author_time:%R> — <summary>",
    },
  },

  -- --------------------------------------------------------------------------
  -- TERMINAL — <leader>t opens a floating shell. Esc Esc to get out of
  -- typing mode, <leader>t again to hide it. The shell keeps running.
  -- --------------------------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    opts = {
      -- Split at the bottom by default, like VS Code's panel, so the terminal
      -- sits alongside your code instead of covering it.
      direction = "horizontal",
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.4)
        end
      end,
      persist_size = true,      -- remember it after you drag the divider
      persist_mode = false,     -- always come back in insert mode, ready to type
      start_in_insert = true,
      float_opts = { border = "rounded", winblend = 0 },
      shell = vim.o.shell,
      -- Ctrl+\ toggles the terminal from ANYWHERE, including from inside the
      -- terminal itself. Space can't work in terminal mode (it would just type
      -- a space into your shell), and Ctrl+\ is one of the few keys no shell
      -- binds by default.
      open_mapping = [[<c-\>]],
    },
  },

  -- --------------------------------------------------------------------------
  -- AUTO-PAIRS — typing ( inserts (), typing <div> closes </div>.
  -- --------------------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },   -- treesitter-aware, so it won't fire in strings
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "xml" },
    opts = {},
  },

  -- --------------------------------------------------------------------------
  -- MARKDOWN RENDERING — draws headings, bullets, tables, code blocks and
  -- checkboxes in the buffer as you edit. The raw text comes back on whatever
  -- line the cursor is on, so editing still works normally.
  -- --------------------------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      -- Render in normal mode only. The moment you enter insert mode the raw
      -- markdown comes back, so you always edit the real characters.
      render_modes = { "n", "c" },

      -- Keep the gutter free for gitsigns instead of markdown signs.
      sign = { enabled = false },

      -- Show the raw text on the cursor's own line, so you can edit a heading
      -- or link without toggling anything off.
      anti_conceal = { enabled = true },

      heading = {
        width = "block",      -- coloured bar only as wide as the text
        left_pad = 0,
        right_pad = 2,
        icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
      },

      code = {
        width = "block",
        border = "thick",
        left_pad = 2,
        right_pad = 2,
        language_name = true,   -- show "js", "go" etc. on the block
        language_icon = true,
      },

      bullet = {
        icons = { "●", "○", "◆", "◇" },
      },

      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
      },

      pipe_table = {
        preset = "round",       -- box-drawing borders, drawn by Ghostty as vectors
      },

      quote = { icon = "▌" },
    },
  },

  -- --------------------------------------------------------------------------
  -- FORMATTING — prettier for JS/JSX/CSS/HTML/JSON, gofmt+goimports for Go,
  -- stylua for Lua. Runs on every save; toggle with <leader>uf.
  -- --------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    init = function()
      vim.g.format_on_save = true   -- <leader>uf flips this
    end,
    opts = {
      formatters_by_ft = {
        javascript      = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript      = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json            = { "prettierd", "prettier", stop_after_first = true },
        jsonc           = { "prettierd", "prettier", stop_after_first = true },
        css             = { "prettierd", "prettier", stop_after_first = true },
        scss            = { "prettierd", "prettier", stop_after_first = true },
        html            = { "prettierd", "prettier", stop_after_first = true },
        yaml            = { "prettierd", "prettier", stop_after_first = true },
        markdown        = { "prettierd", "prettier", stop_after_first = true },
        go              = { "goimports", "gofmt" },
        lua             = { "stylua" },
        c               = { "clang-format" },
      },
      format_on_save = function(bufnr)
        if not vim.g.format_on_save then
          return nil
        end
        -- Never reformat inside dependency folders.
        local path = vim.api.nvim_buf_get_name(bufnr)
        if path:match("/node_modules/") or path:match("/%.git/") then
          return nil
        end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
  },
}
