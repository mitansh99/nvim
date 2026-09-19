# nvim

A hand-rolled Neovim config for a JS/JSX, React Native, Node and Go stack.

Built for someone coming from VS Code who did not want to memorise a new
keymap. Every binding is on the **Space** key and named after the VS Code
action it replaces, and every one of them lives in a single file you can read
top to bottom: [`lua/core/keymaps.lua`](lua/core/keymaps.lua).

No distro, no framework. ~2,100 lines of Lua you own, **~24 ms startup**.

---

## Requirements

| | | Why |
|---|---|---|
| **Neovim ≥ 0.11** | required | uses `vim.lsp.config`, `vim.diagnostic.jump`, `vim.hl.on_yank` |
| `git`, `curl`, `unzip` | required | plugin and tool installation |
| A C compiler + `make` | required | tree-sitter builds ~27 parsers from source |
| `ripgrep` | required | project-wide text search |
| A Nerd Font | required | icons throughout the UI |
| `node` ≥ 18 | for JS/TS | mason installs the JS/TS servers with it |
| `go` | for Go | `gopls` |
| `lazygit` | optional | the `<leader>gg` git UI |
| `wl-clipboard` / `xclip` | **Linux only** | without one, `clipboard=unnamedplus` silently does nothing |

> Ubuntu 24.04's apt ships Neovim **0.9.5**, which is too old. Use the official
> release tarball, an AppImage, or the unstable PPA.

---

## Install

```bash
git clone https://github.com/mitansh99/nvim.git ~/.config/nvim
nvim
```

lazy.nvim bootstraps itself on first launch and installs everything. Parser
compilation takes a couple of minutes. Then check `:Lazy`, `:Mason` and
`:checkhealth`.

On Ubuntu, [`install-ubuntu.sh`](install-ubuntu.sh) does the prerequisites
(Neovim, Node, Go, lazygit, the Nerd Font, clipboard helpers) in one pass.
It is idempotent and backs up rather than deletes.

---

## Keymap

Leader is **Space**. Press it and wait — which-key lists what is available, so
nothing has to be memorised.

| Key | Action | VS Code |
|---|---|---|
| `Space s` | Save | `Ctrl+S` |
| `Space p` | Find file | `Ctrl+P` |
| `Space P` | Command palette | `Ctrl+Shift+P` |
| `Space e` | Toggle file tree | `Ctrl+B` |
| `Space f g` | Search across project | `Ctrl+Shift+F` |
| `Space f R` | Find **and replace** across project | |
| `Space /` | Toggle comment | `Ctrl+/` |
| `Space t` | Terminal | ``Ctrl+` `` |
| `Space g g` | lazygit | |
| `Space 1`…`9` | Jump to tab N | `Cmd+1`…`9` |

Grouped under `Space`: `f` find · `c` code · `g` git · `b` buffers ·
`w` windows · `u` toggles.

Full reference: **[CHEATSHEET.md](CHEATSHEET.md)**, or `:Cheatsheet` in the
editor.

---

## What's set up

**Language servers** — `ts_ls` `eslint` `html` `cssls` `tailwindcss`
`emmet_language_server` `jsonls` `gopls` `clangd` `lua_ls` `yamlls` `bashls`
`dockerls`

**Completion** — [blink.cmp](https://github.com/saghen/blink.cmp), configured to
match VS Code IntelliSense: tsserver **auto-import** (type `useSta`, accept, and
the `import` line is written for you), function-call completion with parameter
placeholders, and inlay hints.

**Formatting** — [conform.nvim](https://github.com/stevearc/conform.nvim) on
save: `prettierd`, `goimports` + `gofumpt`, `stylua`, `clang-format`.
`Space u f` toggles it.

**Syntax** — tree-sitter with 27 parsers, plus custom queries in
[`after/queries/`](after/queries) that colour JSX tags apart. The stock grammar
paints every element name the same, so `<ThemedView>` looked identical to
`return`. Now components, host elements and member expressions each get their
own colour, and closing tags are dimmed.

**Markdown** — renders in the buffer: heading bars, real bullets, `☐`/`☑`
checkboxes, bordered tables, boxed code blocks. The cursor's line always shows
the raw text so editing still works.

**Git** — gitsigns for inline hunks, lazygit for the full UI, diffview for
side-by-side diffs and file history.

**Themes** — 11, switchable with `Space u t` via a picker that previews live
and reverts on `Esc`:

> Zed Match · Zed Match (solid) · Catppuccin Mocha · Tokyo Night · One Dark ·
> Ayu Dark · Ayu Mirage · Gruvbox Dark / Hard / Soft · Nord

`zedmatch` is custom — its palette was **sampled from a screenshot**, reading
flat regions directly and taking the most chromatic pixel of each glyph stroke,
then un-blending it from the background. See
[`lua/themes/zedmatch.lua`](lua/themes/zedmatch.lua), where every colour is
commented with where it came from.

---

## Layout

```
init.lua                    entry point
CHEATSHEET.md               full key reference (:Cheatsheet)
install-ubuntu.sh           Ubuntu bootstrap
bin/ts-cc                   macOS-only compiler shim (see below)
lua/
  core/
    options.lua             editor settings
    keymaps.lua             EVERY keybinding
    autocmds.lua            automatic behaviours
    theme.lua               theme registry + picker
    buffers.lua             layout-safe buffer close, reopen-closed
    windows.lua             pane zoom
  plugins/
    ui.lua                  themes, statusline, tabs, tree, dashboard
    editor.lua              finder, tree-sitter, git, terminal, formatting
    lsp.lua                 language servers and completion
    extras.lua              lazygit, diffview, indent guides, colorizer…
  themes/zedmatch.lua       the sampled colourscheme
after/queries/              custom JSX tag highlighting
colors/                     zedmatch entry points
```

---

## Two workarounds worth knowing

**`bin/ts-cc`** — on macOS, if Xcode is older than the installed Command Line
Tools, `xcrun` hands out a mismatched compiler/SDK pair and every tree-sitter
parser fails to link with `unknown architecture arm64e.x1`. This shim forces a
matched pair. It is guarded by `vim.fn.has("mac")` and is inert on Linux.
Delete it once Xcode is current.

**tree-sitter markdown fences** — nvim-treesitter's `master` branch states it
does not support Neovim 0.12, and its markdown injection directive throws
`attempt to call method 'range'` on any `` ```lang `` fence, which killed
highlighting *and* markdown rendering for the whole file. The directive is
re-registered in
[`lua/plugins/editor.lua`](lua/plugins/editor.lua) with the fix. Remove it after
migrating to the `main` branch.

---

## Syncing two machines

```bash
git pull                                  # before editing
git add -A && git commit -m "…" && git push
```

`lazy-lock.json` is committed on purpose so both machines resolve identical
plugin versions. After a pull that changes it, run `:Lazy restore`.
