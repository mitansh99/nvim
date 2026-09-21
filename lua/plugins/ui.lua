-- ============================================================================
--  UI — themes, statusline, file tabs, file tree, dashboard, the Space menu.
-- ============================================================================

return {

  -- --------------------------------------------------------------------------
  -- THEMES. Three installed; <leader>ut cycles. All set up transparent so
  -- Ghostty's background blur shows through.
  -- --------------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      show_end_of_buffer = false,
      styles = {
        comments = { "italic" },
        keywords = { "italic" },
      },
      integrations = {
        blink_cmp = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        neotree = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
        alpha = true,
        mason = true,
        native_lsp = { enabled = true, underlines = { errors = { "undercurl" } } },
      },
      custom_highlights = function(colors)
        -- Keep floating windows readable against a blurred background.
        return {
          NormalFloat = { bg = colors.none },
          FloatBorder = { fg = colors.blue, bg = colors.none },
        }
      end,
    },
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 900,
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
        comments = { italic = true },
      },
    },
  },

  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 900,
    opts = {
      style = "dark",
      transparent = true,
      code_style = { comments = "italic" },
    },
  },

  -- Ayu — provides ayu-dark and ayu-mirage.
  -- No built-in transparency flag, so the backgrounds are cleared by hand.
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 900,
    main = "ayu",   -- lazy.nvim can't guess this from the repo name "neovim-ayu"
    opts = {
      overrides = {
        Normal       = { bg = "None" },
        NormalNC     = { bg = "None" },
        NormalFloat  = { bg = "None" },
        SignColumn   = { bg = "None" },
        LineNr       = { bg = "None" },
        Folded       = { bg = "None" },
        FoldColumn   = { bg = "None" },
        ColorColumn  = { bg = "None" },
        VertSplit    = { bg = "None" },
        WinSeparator = { bg = "None" },
        EndOfBuffer  = { bg = "None" },
        TabLineFill  = { bg = "None" },
      },
    },
  },

  -- Gruvbox — one plugin, three contrast levels. core/theme.lua re-runs
  -- setup() with a different `contrast` for each of the three menu entries.
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 900,
    opts = {
      terminal_colors = true,
      transparent_mode = true,
      contrast = "",              -- overridden per variant by the theme picker
      italic = { strings = false, comments = true, folds = true },
    },
  },

  -- Nord — the family the screenshot's "Yukinord" belongs to.
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 900,
    opts = {
      transparent = true,
      styles = { comments = { italic = true } },
    },
  },

  -- --------------------------------------------------------------------------
  -- Icons. Requires a Nerd Font in your terminal — you already have
  -- JetBrainsMono Nerd Font installed.
  -- --------------------------------------------------------------------------
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "MunifTanjim/nui.nvim",        lazy = true },
  { "nvim-lua/plenary.nvim",       lazy = true },

  -- --------------------------------------------------------------------------
  -- WHICH-KEY — the popup that appears when you press Space. This is what
  -- means you never have to memorise a keybinding.
  -- --------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      icons = { mappings = false },
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>c", group = "Code" },
        { "<leader>g", group = "Git" },
        { "<leader>b", group = "Buffers / open files" },
        { "<leader>w", group = "Windows / panes" },
        { "<leader>u", group = "UI toggles" },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- STATUSLINE (the bar at the bottom)
  -- --------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "alpha", "neo-tree" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = {
          { "filename", path = 1 },
          { "diagnostics", sources = { "nvim_lsp" } },
        },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- BUFFERLINE — open files as tabs along the top, like VS Code.
  -- --------------------------------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_close_icon = false,
        always_show_bufferline = false,
        offsets = {
          {
            filetype = "neo-tree",
            text = "EXPLORER",
            highlight = "Directory",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- FILE TREE — the sidebar. <leader>e toggles it.
  -- Inside the tree: a = add, d = delete, r = rename, c = copy, x = cut,
  -- p = paste, H = toggle hidden files, ? = show all tree keys.
  -- --------------------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      window = {
        position = "right",   -- sidebar on the right, like the screenshot
        width = 34,
        mappings = {
          ["<space>"] = "none",  -- don't steal the leader key inside the tree
          ["l"] = "open",
          ["h"] = "close_node",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },  -- highlight the file you're editing
        use_libuv_file_watcher = true,             -- auto-refresh on disk changes
        filtered_items = {
          visible = false,
          hide_dotfiles = false,   -- show .env, .eslintrc etc.
          hide_gitignored = true,
          hide_by_name = { "node_modules", ".git", ".DS_Store" },
        },
      },
      default_component_configs = {
        indent = { with_expanders = true },
        git_status = {
          symbols = {
            added = "", modified = "", deleted = "",
            renamed = "󰁕", untracked = "", ignored = "",
            unstaged = "󰄱", staged = "", conflict = "",
          },
        },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- DASHBOARD — the greeter screen when you run bare `nvim`.
  -- --------------------------------------------------------------------------
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗ ",
        "  ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║ ",
        "  ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║ ",
        "  ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ",
        "  ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ",
        "                                                     ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("p", "  Find file",       "<cmd>Telescope find_files<cr>"),
        dashboard.button("r", "  Recent files",    "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("g", "  Find text",       "<cmd>Telescope live_grep<cr>"),
        dashboard.button("n", "  New file",        "<cmd>ene | startinsert<cr>"),
        dashboard.button("e", "  File tree",       "<cmd>Neotree toggle<cr>"),
        dashboard.button("c", "  Config",          "<cmd>Telescope find_files cwd=~/.config/nvim<cr>"),
        dashboard.button("?", "  Cheatsheet",      "<cmd>Cheatsheet<cr>"),
        dashboard.button("l", "󰒲  Plugins",         "<cmd>Lazy<cr>"),
        dashboard.button("q", "  Quit",            "<cmd>qa<cr>"),
      }

      dashboard.section.footer.val = "Press SPACE anywhere to see what you can do"

      dashboard.section.header.opts.hl  = "Type"
      dashboard.section.buttons.opts.hl = "Keyword"
      dashboard.section.footer.opts.hl  = "Comment"

      alpha.setup(dashboard.opts)
    end,
  },
}
