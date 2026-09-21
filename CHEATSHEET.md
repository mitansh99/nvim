# Neovim cheatsheet

Leader is the **Space bar**. Press Space and wait — a menu shows your options.
Open this file any time with `:Cheatsheet` or `Space u ?`.

---

## The 9 keys to learn first

| Key | Does | VS Code equivalent |
|---|---|---|
| `Space s` | Save file | `Ctrl+S` |
| `Space p` | Find file by name | `Ctrl+P` |
| `Space P` | Command palette | `Ctrl+Shift+P` |
| `Space e` | Toggle file tree sidebar | `Ctrl+B` |
| `Space f g` | Search text across project | `Ctrl+Shift+F` |
| `Space /` | Toggle comment | `Ctrl+/` |
| `Space t` | Terminal in a split below | ``Ctrl+` `` |
| `Space T` | Terminal in a split to the right | |
| `Ctrl+\` | Toggle terminal from anywhere, incl. inside it | |

From inside the terminal, `Ctrl+h/j/k/l` jump straight to a code pane.
That costs the shell `Ctrl+h` (backspace), `Ctrl+j` (Enter), `Ctrl+k`
(kill to end of line) and `Ctrl+l` (clear screen) — use Backspace, Enter,
`Ctrl+u` and `clear` instead. `Ctrl+w` is untouched.
| `Space q` | Close current file | `Ctrl+W` |
| `Esc` | Clear search highlight / leave insert mode | `Esc` |

---

## Modes — the one vim concept you must have

Neovim starts in **Normal** mode, where letters are commands, not text.

| To get to | Press | What it's for |
|---|---|---|
| Insert mode | `i` | Typing text. This is "normal editing". |
| Normal mode | `Esc` | Commands, navigation, everything else. |
| Visual mode | `v` | Selecting text (or just drag with the mouse). |
| Visual line | `V` | Selecting whole lines. |
| Command line | `:` | `:w` save, `:q` quit, `:wq` both. |

If you ever feel stuck: press `Esc` twice. You're back in Normal mode.

---

## Space menus

### `Space f` — Find
| Key | Does |
|---|---|
| `Space f f` | Files by name |
| `Space f g` | Text anywhere in the project |
| `Space f w` | The word under your cursor, project-wide |
| `Space f b` | Switch between open files |
| `Space f r` | Recently opened files |
| `Space f s` | Symbols (functions/components) in this file |
| `Space f /` | Search inside this file |
| `Space f k` | Search every keybinding you have |
| `Space f R` | Find AND **replace** across the project |
| `Space f t` | TODO / FIXME comments |
| `Space f c` | Open this config |
| `Space f h` | Neovim's own help |

Inside a finder: type to filter, `Ctrl+j`/`Ctrl+k` to move, `Enter` to open, `Esc` to cancel.

### `Space c` — Code
| Key | Does | VS Code |
|---|---|---|
| `Space c a` | Quick fix / code action | `Ctrl+.` |
| `Space c r` | Rename symbol everywhere | `F2` |
| `Space c f` | Format file | `Shift+Alt+F` |
| `Space c h` | Show docs for symbol | hover |
| `Space c d` | Explain the error on this line | |
| `Space c D` | Go to definition | `F12` |
| `Space c R` | Find all references | `Shift+F12` |
| `Space c i` | Go to implementation | |

### `Space g` — Git
| Key | Does |
|---|---|
| `Space g b` | Who wrote this line |
| `Space g B` | Toggle always-on inline blame |
| `Space g p` | Preview the change on this line |
| `Space g s` | Stage this change |
| `Space g u` | Unstage it |
| `Space g r` | Discard this change |
| `Space g d` | Diff this file |
| `Space g f` | List changed files |
| `Space g c` | Browse commits |
| `Space g g` | **lazygit** — full git UI |
| `Space g v` | Diff view of all changes |
| `Space g h` | History of this file |
| `Space g H` | History of the whole repo |
| `Space g x` | Close the diff view |
| `]g` / `[g` | Jump to next / previous change |

### `Space b` — Open files (the tabs at the top)
| Key | Does | VS Code |
|---|---|---|
| `Space 1` … `Space 8` | Jump to that tab | `Cmd+1` … `Cmd+8` |
| `Space 9` | Jump to the last tab | `Cmd+9` |
| `Space b b` | Pick a tab by letter | |
| `Space b n` / `Shift+l` | Next file | `Ctrl+Tab` |
| `Space b p` / `Shift+h` | Previous file | |
| `Space b d` | Close this file | `Ctrl+W` |
| `Space b D` | Close it, discard unsaved changes | |
| `Space b u` | Reopen the file you just closed | `Ctrl+Shift+T` |
| `Space b o` | Close all the others | |
| `Space b H` | Close all tabs to the left | |
| `Space b L` | Close all tabs to the right | |
| `Space b l` | Fuzzy-switch between open files | |

Closing a file never closes the pane it was in, and never silently throws away
unsaved changes — the close commands skip modified files and tell you.

### `Space w` — Panes
| Key | Does |
|---|---|
| `Space w v` | Split current file right |
| `Space w s` | Split current file below |
| `Space w c` | Close this pane |
| `Space w o` | Close all other panes |
| `Space w h/j/k/l` | Move focus left/down/up/right |
| `Ctrl+h/j/k/l` | Same thing, faster |
| `Space w m` | Maximise this pane / restore |
| `Space w ←/→` | Narrower / wider |
| `Space w ↑/↓` | Taller / shorter |
| `Space w =` | Equalise all panes |

**Opening a *different* file in a split** — the keys above split the file you're
already in. To put another file beside it:

| Where | Key | Opens in |
|---|---|---|
| Finder (`Space p`) | `Ctrl+v` | vertical split |
| | `Ctrl+x` | horizontal split |
| | `Ctrl+t` | new tab |
| File tree (`Space e`) | `s` | vertical split |
| | `S` | horizontal split |
| | `t` | new tab |

So the usual move is `Space p`, type part of the name, then `Ctrl+v`.

### `Space u` — Toggles
| Key | Does |
|---|---|
| `Space u t` | Theme picker — live preview, Enter keeps, Esc reverts |
| `Space u f` | Turn format-on-save on/off |
| `Space u w` | Line wrap |
| `Space u n` | Relative line numbers |
| `Space u d` | Error squiggles |
| `Space u l` | Plugin manager (`:Lazy`) |
| `Space u i` | Toggle inlay hints |
| `Space u c` | Toggle colour swatches |
| `Space u m` | Toggle markdown rendering |
| `Space u M` | Language server manager (`:Mason`) |
| `Space u ?` | This cheatsheet |

---

## Selecting and jumping by code structure

| Key | Does |
|---|---|
| `vaf` / `vif` | select a whole function / just its body |
| `vac` / `vic` | select a class / its body |
| `vaa` / `via` | select a parameter |
| `]f` / `[f` | jump to next / previous function |
| `Space c A` / `Space c a` | swap a parameter right / left |

Swap `v` for `d` to delete or `c` to change — `dif` deletes a function body.

## Surrounding text

| Key | Does |
|---|---|
| `cs"'` | change double quotes to single |
| `ysiw)` | wrap the word in parentheses |
| `dst` | delete the surrounding JSX/HTML tag |
| `S` in visual mode | surround the selection |

---

## Autocomplete

`Tab` / `Shift+Tab` cycle, `Enter` accepts, `Ctrl+Space` forces the menu open,
`Ctrl+e` dismisses.

It behaves like VS Code's IntelliSense:

- **Auto-import** — type `useSta`, accept `useState`, and
  `import { useState } from 'react';` is written at the top for you. Works for
  anything importable from your project or `node_modules`.
- **Function calls** — accepting a function inserts its parentheses and
  parameter placeholders; `Tab` jumps between them.
- **Inlay hints** — parameter names and inferred types shown inline in grey.
  `Space u i` toggles them.

Give tsserver about 8 seconds after opening a project before auto-imports
appear; it is indexing. VS Code has the same pause.

---

## Markdown

Open any `.md` file and it renders in place: headings get icons and coloured
bars, `- [ ]` becomes ☐, tables get real borders, code blocks get a boxed
background with the language name.

The line your **cursor** is on always shows the raw markdown, so you can edit it
normally. Move off the line and it renders again. `Space u m` turns rendering
off entirely.

Markdown also soft-wraps at the window edge, and `j`/`k` move by visual line so
wrapped paragraphs navigate naturally. Code files are unaffected.

---

## Themes

`Space u t` opens a searchable list. Moving the cursor applies the theme to your
real code immediately; `Enter` keeps it, `Esc` puts back what you had. Your
choice survives restarts.

| | |
|---|---|
| **Zed Match** | sampled from your screenshot, transparent |
| **Zed Match (solid)** | same, with its real #1d2129 backdrop |
| Catppuccin Mocha | warm dark |
| Tokyo Night | cooler, higher contrast |
| One Dark | closest to VS Code's Dark+ |
| Ayu Dark | very dark, minimal |
| Ayu Mirage | softer blue-grey |
| Gruvbox Dark / Hard / Soft | warm retro |
| Nord | cool arctic blue |

JSX/TSX tags are colour-coded by what they are, so a wall of components is
readable:

| | |
|---|---|
| `<ThemedView>` | purple — your own components (capitalised) |
| `</ThemedView>` | dimmed purple — closing tags recede |
| `<div>` `<span>` | blue — host elements (lowercase) |
| `<Animated.View>` | pink — member expressions |
| `style=` `type=` | italic tan — attributes |

The rules live in `after/queries/{tsx,javascript}/highlights.scm`.

All themes are transparent so Ghostty's blur shows through. To add one: install the
plugin in `lua/plugins/ui.lua`, then add a row to `M.themes` in
`lua/core/theme.lua`.

---

## Moving around (no leader needed)

| Key | Does |
|---|---|
| `h` `j` `k` `l` | left, down, up, right (arrow keys also work) |
| `5j` | down 5 lines — this is what relative numbers are for |
| `w` / `b` | forward / back one word |
| `0` / `$` | start / end of line |
| `gg` / `G` | top / bottom of file |
| `Ctrl+d` / `Ctrl+u` | half page down / up |
| `gd` | go to definition |
| `gr` | find references |
| `K` | show docs for the thing under the cursor |
| `]d` / `[d` | next / previous error |
| `/word` then `Enter` | search; `n` next match, `N` previous |

## Editing (no leader needed)

| Key | Does |
|---|---|
| `i` / `a` | insert before / after cursor |
| `o` / `O` | new line below / above, and start typing |
| `dd` | delete line |
| `yy` | copy line |
| `p` | paste |
| `u` | undo |
| `Ctrl+r` | redo |
| `cw` | change word |
| `ciw` | change the whole word you're inside |
| `ci"` | change what's inside the quotes |
| `ci(` | change what's inside the brackets |

The last three are the ones that make vim feel worth it. `ci"` from anywhere
inside a string replaces the whole string.

## Visual mode

| Key | Does | VS Code |
|---|---|---|
| `v` then move | select | click-drag |
| `V` | select whole lines | |
| `J` / `K` | move the selection down / up | `Alt+Down` / `Alt+Up` |
| `<` / `>` | indent left / right | `Tab` / `Shift+Tab` |
| `Space /` | comment the selection | `Ctrl+/` |
| `y` / `d` | copy / delete the selection | |

---

## File tree (`Space e`)

Inside the tree: `a` add file, `A` add folder, `d` delete, `r` rename,
`c` copy, `x` cut, `p` paste, `H` show hidden files, `?` all tree keys,
`l`/`Enter` open, `h` collapse, `q` close the tree.

## Autocomplete

`Tab` / `Shift+Tab` cycle the suggestions, `Enter` accepts,
`Ctrl+Space` forces the menu open, `Ctrl+e` dismisses it.

---

## Where things live

```
~/.config/nvim/
├── init.lua              entry point
├── CHEATSHEET.md         this file
└── lua/
    ├── core/
    │   ├── options.lua   editor settings
    │   ├── keymaps.lua   EVERY keybinding
    │   ├── autocmds.lua  automatic behaviours
    │   └── theme.lua     theme switcher
    └── plugins/
        ├── ui.lua        themes, statusline, tabs, tree, dashboard
        ├── editor.lua    finder, treesitter, git, terminal, formatting
        └── lsp.lua       language servers and autocomplete
```

Useful commands: `:Lazy` plugins · `:Mason` language servers ·
`:LspInfo` what's attached to this file · `:ConformInfo` what formats it ·
`:checkhealth` diagnose problems.
