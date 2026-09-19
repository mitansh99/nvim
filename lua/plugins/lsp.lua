-- ============================================================================
--  LANGUAGE SUPPORT — autocomplete, go-to-definition, rename, error squiggles.
--
--  Mason downloads and manages the language servers for you. Run :Mason to
--  see what's installed; run :LspInfo to see what's attached to a file.
-- ============================================================================

return {

  -- --------------------------------------------------------------------------
  -- AUTOCOMPLETE. Tab / Shift-Tab cycle the list, Enter accepts,
  -- Ctrl+Space forces the menu open, Esc dismisses it.
  -- --------------------------------------------------------------------------
  {
    "saghen/blink.cmp",
    version = "*",                       -- uses a prebuilt binary, no Rust needed
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"]   = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"]     = { "hide", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        ghost_text = { enabled = false },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  -- --------------------------------------------------------------------------
  -- MASON — installs language servers and formatters into ~/.local/share/nvim.
  -- --------------------------------------------------------------------------
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = { ui = { border = "rounded" } },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "prettierd",       -- fast prettier daemon, for JS/JSX/CSS/HTML/JSON
        "stylua",          -- Lua formatter (for this config)
        "goimports",       -- Go: format + fix imports
        "gofumpt",         -- Go: stricter gofmt
      },
      run_on_start = true,
      auto_update = false,
    },
  },

  -- --------------------------------------------------------------------------
  -- THE LANGUAGE SERVERS THEMSELVES
  -- Chosen from what's actually in your projects:
  --   ts_ls     -> JS + JSX + TS (diasimosapp, diasimos-dev-web, payment-micro)
  --   eslint    -> your client's eslint.config.js rules, shown inline
  --   tailwind  -> class autocomplete (your web client uses tailwind)
  --   emmet     -> type "div.card" + Tab to expand into JSX
  --   html/css  -> the 364 .css files in your web client
  --   jsonls    -> package.json / app.json / tsconfig validation
  --   gopls     -> Go
  --   clangd    -> your Desktop/learn/C files
  --   lua_ls    -> editing this Neovim config
  -- --------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local servers = {
        "ts_ls",
        "eslint",
        "html",
        "cssls",
        "tailwindcss",
        "emmet_language_server",
        "jsonls",
        "gopls",
        "clangd",
        "lua_ls",
        "yamlls",       -- bitbucket-pipelines.yml, docker-compose
        "bashls",       -- your 13 shell scripts
        "dockerls",
      }

      -- Tell every server that blink.cmp is handling completion.
      --
      -- The second argument matters: without it blink returns ONLY its own
      -- completion capabilities and throws away Neovim's defaults, which
      -- include semanticTokens. The result was that ts_ls advertised semantic
      -- token support, Neovim never asked for it, and semantic highlighting
      -- was silently off in every language. Passing `true` merges the defaults
      -- back in.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities({}, true),
      })

      -- lua_ls: stop it warning that `vim` is an undefined global.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- eslint: fix what it can automatically when you save.
      vim.lsp.config("eslint", {
        settings = { workingDirectories = { mode = "auto" } },
      })

      -- Inlay hints: the greyed-in parameter names and inferred types that
      -- VS Code shows inline. Toggle them with <leader>ui.
      local inlay_hints = {
        includeInlayParameterNameHints = "all",       -- all | literals | none
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }

      -- ts_ls: match VS Code's IntelliSense.
      --
      -- Without `preferences`, tsserver only completes symbols already in
      -- scope: typing "useSta" in a file that hasn't imported it offered
      -- NOTHING. VS Code sends these preferences (its "Auto Imports" setting,
      -- on by default), which is what makes it suggest anything importable
      -- and write the import line for you when you accept.
      --
      -- Measured on client/src/main.jsx: 1071 items before, 1342 after, and
      -- useState now arrives carrying `import { useState } from 'react';`.
      vim.lsp.config("ts_ls", {
        init_options = {
          hostInfo = "neovim",
          preferences = {
            -- suggest symbols from other modules and add the import on accept
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            -- let the server send snippet-style completions
            includeCompletionsWithSnippetText = true,
            includeCompletionsWithInsertText = true,
            -- offer `?.` where the type can be null
            includeAutomaticOptionalChainCompletions = true,
            -- prefer "./utils" over "../../src/utils"
            importModuleSpecifierPreference = "shortest",
          },
        },
        -- Workspace settings. Paths verified against the server source:
        -- completions.completeFunctionCalls  (cli.mjs:25629)
        -- {javascript,typescript}.inlayHints (cli.mjs:23569)
        settings = {
          completions = {
            -- Accepting a function inserts its parentheses and parameter
            -- placeholders; Tab jumps between them.
            completeFunctionCalls = true,
          },
          javascript = { inlayHints = inlay_hints },
          typescript = { inlayHints = inlay_hints },
        },
      })

      -- tailwindcss: lspconfig's default filetype list is huge and includes
      -- markdown, so it was attaching to every .md file. Restrict it to where
      -- you actually write classes.
      vim.lsp.config("tailwindcss", {
        filetypes = {
          "html", "css", "scss", "javascript", "javascriptreact",
          "typescript", "typescriptreact",
        },
      })

      -- emmet: also active inside JSX, not just .html.
      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact" },
      })

      -- gopls: same inlay hints, using its own option names.
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })

      -- Turn inlay hints on for every buffer that has a server supporting them.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_inlay_hints", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            pcall(vim.lsp.inlay_hint.enable, true, { bufnr = event.buf })
          end
        end,
      })

      require("mason").setup({ ui = { border = "rounded" } })
      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = true,   -- enables each server once Mason installs it
      })
    end,
  },
}
