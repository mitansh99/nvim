-- ============================================================================
--  zedmatch — a colourscheme sampled from the Zed screenshot you sent.
--
--  The palette was measured from the image itself, not eyeballed: background
--  and UI colours read straight off flat regions, syntax colours taken from
--  the most chromatic pixel of each glyph stroke and then un-blended from the
--  background (antialiasing mixes every glyph toward the backdrop, which makes
--  measured text look darker and flatter than it really is).
--
--  Measured directly:
--    editor bg  #1d2129      sidebar bg #14181d
--    selection  #3b4858      border     #3b404c
--
--  Two variants are registered: `zedmatch` (transparent, so Ghostty's blur
--  shows through) and `zedmatch-solid` (paints the real #1d2129 backdrop).
-- ============================================================================

local M = {}

M.palette = {
  -- surfaces (measured from flat regions of the screenshot)
  bg          = "#1d2129",
  bg_dark     = "#14181d",
  bg_light    = "#252b34",
  cursorline  = "#232832",
  selection   = "#3b4858",
  border      = "#3b404c",

  -- text
  fg          = "#c4d9f4",
  fg_dim      = "#9fbad3",
  comment     = "#68758a",
  line_nr     = "#6f7986",  -- measured from the screenshot gutter (#71757d), nudged blue
  line_nr_cur = "#9fbad3",

  -- syntax (un-blended from the glyph samples)
  keyword     = "#6da1bd",  -- function, return, const, export, await
  func        = "#c7a372",  -- formatPrice, AdminCustomersPage, useState
  type        = "#8ba178",  -- number, string, Customer
  string      = "#b0735b",  -- "id-ID", "/api/admin/users"
  number      = "#cd9a6c",
  variable    = "#9fbad3",  -- customers, response, style
  property    = "#8fa5b9",

  -- derived, kept inside the same muted family
  red         = "#bf6b5c",
  orange      = "#cd9a6c",
  yellow      = "#d3b782",
  green       = "#8ba178",
  cyan        = "#7fb4c4",
  blue        = "#6da1bd",
  purple      = "#a98bc4",

  -- JSX tag roles. The stock grammar paints every element name with the same
  -- @tag colour, which in React Native means <ThemedView>, <ThemedText> and
  -- <Collapsible> are indistinguishable from each other AND from keywords.
  -- after/queries/{tsx,javascript}/highlights.scm splits them; these are the
  -- colours. Closing tags are dimmed so the eye tracks the opening tags.
  tag_component     = "#a98bc4",  -- <ThemedView>   custom component
  tag_component_dim = "#836e9a",  -- </ThemedView>
  tag_builtin       = "#6da1bd",  -- <div> <span>   host element
  tag_builtin_dim   = "#557b92",  -- </div>
  tag_member        = "#c58fb0",  -- <Animated.View>
  tag_member_dim    = "#906c86",

  -- Indent guides. These MUST NOT inherit Whitespace: that is #252b34, which
  -- against the #1d2129 background scores 1.13 contrast and is invisible.
  -- 2.13 is a little stronger than Catppuccin (1.80) or Tokyo Night (1.74)
  -- use, because this theme runs transparent and the blurred desktop behind
  -- it washes faint lines out.
  indent            = "#4a5565",
  indent_scope      = "#7e93a8",
}

--- @param opts? { transparent?: boolean }
function M.load(opts)
  opts = opts or {}
  local transparent = opts.transparent ~= false
  local c = M.palette
  local bg = transparent and "NONE" or c.bg
  local bg_side = transparent and "NONE" or c.bg_dark

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = transparent and "zedmatch" or "zedmatch-solid"

  local hl = function(group, spec) vim.api.nvim_set_hl(0, group, spec) end

  local groups = {
    -- ---------- editor surfaces ----------
    Normal        = { fg = c.fg, bg = bg },
    NormalNC      = { fg = c.fg, bg = bg },
    NormalFloat   = { fg = c.fg, bg = bg },
    FloatBorder   = { fg = c.border, bg = bg },
    FloatTitle    = { fg = c.keyword, bg = bg, bold = true },
    SignColumn    = { bg = bg },
    EndOfBuffer   = { fg = bg_side == "NONE" and c.bg or c.bg_dark },
    ColorColumn   = { bg = c.bg_light },
    CursorLine    = { bg = c.cursorline },
    CursorLineNr  = { fg = c.line_nr_cur, bold = true },
    LineNr        = { fg = c.line_nr },
    Cursor        = { fg = c.bg, bg = c.fg },
    Visual        = { bg = c.selection },
    VisualNOS     = { bg = c.selection },
    Search        = { fg = c.bg, bg = c.yellow },
    IncSearch     = { fg = c.bg, bg = c.orange },
    CurSearch     = { fg = c.bg, bg = c.orange },
    MatchParen    = { fg = c.orange, bold = true },
    Folded        = { fg = c.comment, bg = c.bg_light },
    FoldColumn    = { fg = c.line_nr, bg = bg },
    WinSeparator  = { fg = c.border, bg = bg },
    VertSplit     = { fg = c.border, bg = bg },
    Whitespace    = { fg = c.bg_light },
    NonText       = { fg = c.line_nr },
    SpecialKey    = { fg = c.line_nr },
    Directory     = { fg = c.keyword },
    Title         = { fg = c.func, bold = true },
    Question      = { fg = c.green },
    MoreMsg       = { fg = c.green },
    ModeMsg       = { fg = c.fg, bold = true },
    ErrorMsg      = { fg = c.red },
    WarningMsg    = { fg = c.yellow },
    Conceal       = { fg = c.comment },
    QuickFixLine  = { bg = c.selection },
    Winbar        = { fg = c.fg_dim, bg = bg },
    WinbarNC      = { fg = c.comment, bg = bg },

    -- ---------- popup menu ----------
    Pmenu         = { fg = c.fg_dim, bg = transparent and "NONE" or c.bg_dark },
    PmenuSel      = { fg = c.fg, bg = c.selection, bold = true },
    PmenuSbar     = { bg = c.bg_light },
    PmenuThumb    = { bg = c.border },
    PmenuKind     = { fg = c.func, bg = transparent and "NONE" or c.bg_dark },
    PmenuExtra    = { fg = c.comment, bg = transparent and "NONE" or c.bg_dark },

    -- ---------- statusline / tabs ----------
    StatusLine    = { fg = c.fg_dim, bg = transparent and "NONE" or c.bg_dark },
    StatusLineNC  = { fg = c.comment, bg = transparent and "NONE" or c.bg_dark },
    TabLine       = { fg = c.comment, bg = transparent and "NONE" or c.bg_dark },
    TabLineSel    = { fg = c.fg, bg = bg, bold = true },
    TabLineFill   = { bg = transparent and "NONE" or c.bg_dark },

    -- ---------- classic syntax ----------
    Comment       = { fg = c.comment, italic = true },
    Constant      = { fg = c.orange },
    String        = { fg = c.string },
    Character     = { fg = c.string },
    Number        = { fg = c.number },
    Float         = { fg = c.number },
    Boolean       = { fg = c.orange },
    Identifier    = { fg = c.variable },
    Function      = { fg = c.func },
    Statement     = { fg = c.keyword },
    Conditional   = { fg = c.keyword },
    Repeat        = { fg = c.keyword },
    Label         = { fg = c.keyword },
    Operator      = { fg = c.fg_dim },
    Keyword       = { fg = c.keyword },
    Exception     = { fg = c.keyword },
    PreProc       = { fg = c.purple },
    Include       = { fg = c.keyword },
    Define        = { fg = c.purple },
    Macro         = { fg = c.purple },
    Type          = { fg = c.type },
    StorageClass  = { fg = c.keyword },
    Structure     = { fg = c.type },
    Typedef       = { fg = c.type },
    Special       = { fg = c.cyan },
    SpecialComment= { fg = c.comment, italic = true },
    Delimiter     = { fg = c.fg_dim },
    Todo          = { fg = c.bg, bg = c.yellow, bold = true },
    Error         = { fg = c.red },
    Underlined    = { underline = true },

    -- ---------- treesitter ----------
    ["@comment"]              = { link = "Comment" },
    ["@comment.todo"]         = { fg = c.bg, bg = c.yellow, bold = true },
    ["@comment.error"]        = { fg = c.bg, bg = c.red, bold = true },
    ["@comment.warning"]      = { fg = c.bg, bg = c.yellow, bold = true },
    ["@comment.note"]         = { fg = c.bg, bg = c.cyan, bold = true },
    ["@variable"]             = { fg = c.variable },
    ["@variable.builtin"]     = { fg = c.red },
    ["@variable.parameter"]   = { fg = c.fg_dim, italic = true },
    ["@variable.member"]      = { fg = c.property },
    ["@constant"]             = { fg = c.orange },
    ["@constant.builtin"]     = { fg = c.orange },
    ["@constant.macro"]       = { fg = c.purple },
    ["@module"]               = { fg = c.type },
    ["@string"]               = { fg = c.string },
    ["@string.escape"]        = { fg = c.cyan },
    ["@string.special"]       = { fg = c.cyan },
    ["@string.regexp"]        = { fg = c.cyan },
    ["@character"]            = { fg = c.string },
    ["@number"]               = { fg = c.number },
    ["@boolean"]              = { fg = c.orange },
    ["@function"]             = { fg = c.func },
    ["@function.builtin"]     = { fg = c.func },
    ["@function.call"]        = { fg = c.func },
    ["@function.method"]      = { fg = c.func },
    ["@function.method.call"] = { fg = c.func },
    ["@constructor"]          = { fg = c.type },
    ["@keyword"]              = { fg = c.keyword },
    ["@keyword.function"]     = { fg = c.keyword },
    ["@keyword.operator"]     = { fg = c.keyword },
    ["@keyword.return"]       = { fg = c.keyword },
    ["@keyword.import"]       = { fg = c.keyword },
    ["@keyword.conditional"]  = { fg = c.keyword },
    ["@keyword.repeat"]       = { fg = c.keyword },
    ["@keyword.exception"]    = { fg = c.keyword },
    ["@operator"]             = { fg = c.fg_dim },
    ["@punctuation.delimiter"]= { fg = c.fg_dim },
    ["@punctuation.bracket"]  = { fg = c.fg_dim },
    ["@punctuation.special"]  = { fg = c.cyan },
    ["@type"]                 = { fg = c.type },
    ["@type.builtin"]         = { fg = c.type },
    ["@type.definition"]      = { fg = c.type },
    ["@attribute"]            = { fg = c.purple },
    ["@property"]             = { fg = c.property },
    ["@label"]                = { fg = c.keyword },
    ["@tag"]                       = { fg = c.tag_component },
    ["@tag.component"]             = { fg = c.tag_component, bold = true },
    ["@tag.component.closing"]     = { fg = c.tag_component_dim },
    ["@tag.builtin"]               = { fg = c.tag_builtin },
    ["@tag.builtin.closing"]       = { fg = c.tag_builtin_dim },
    ["@tag.member"]                = { fg = c.tag_member, bold = true },
    ["@tag.member.closing"]        = { fg = c.tag_member_dim },
    ["@tag.attribute"]             = { fg = c.func, italic = true },
    ["@tag.delimiter"]             = { fg = c.line_nr },
    ["@string.special.url"]        = { fg = c.cyan, underline = true },
    ["@markup.heading"]       = { fg = c.func, bold = true },
    ["@markup.strong"]        = { fg = c.fg, bold = true },
    ["@markup.italic"]        = { fg = c.fg, italic = true },
    ["@markup.link"]          = { fg = c.cyan, underline = true },
    ["@markup.link.url"]      = { fg = c.cyan, underline = true },
    ["@markup.raw"]           = { fg = c.string },
    ["@markup.list"]          = { fg = c.keyword },
    ["@markup.quote"]         = { fg = c.comment, italic = true },
    ["@diff.plus"]            = { fg = c.green },
    ["@diff.minus"]           = { fg = c.red },

    -- ---------- LSP ----------
    ["@lsp.type.class"]        = { fg = c.type },
    ["@lsp.type.interface"]    = { fg = c.type },
    ["@lsp.type.enum"]         = { fg = c.type },
    ["@lsp.type.namespace"]    = { fg = c.type },
    ["@lsp.type.function"]     = { fg = c.func },
    ["@lsp.type.method"]       = { fg = c.func },
    ["@lsp.type.parameter"]    = { fg = c.fg_dim, italic = true },
    ["@lsp.type.property"]     = { fg = c.property },
    ["@lsp.type.variable"]     = { fg = c.variable },
    ["@lsp.type.keyword"]      = { fg = c.keyword },
    ["@lsp.type.string"]       = { fg = c.string },
    ["@lsp.type.number"]       = { fg = c.number },
    ["@lsp.type.comment"]      = { link = "Comment" },
    ["@lsp.mod.readonly"]      = { fg = c.orange },
    LspInlayHint               = { fg = c.line_nr, italic = true },
    LspSignatureActiveParameter= { fg = c.orange, bold = true },
    LspReferenceText           = { bg = c.bg_light },
    LspReferenceRead           = { bg = c.bg_light },
    LspReferenceWrite          = { bg = c.bg_light, underline = true },

    -- ---------- diagnostics ----------
    DiagnosticError            = { fg = c.red },
    DiagnosticWarn             = { fg = c.yellow },
    DiagnosticInfo             = { fg = c.blue },
    DiagnosticHint             = { fg = c.cyan },
    DiagnosticOk               = { fg = c.green },
    DiagnosticUnderlineError   = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn    = { undercurl = true, sp = c.yellow },
    DiagnosticUnderlineInfo    = { undercurl = true, sp = c.blue },
    DiagnosticUnderlineHint    = { undercurl = true, sp = c.cyan },
    DiagnosticVirtualTextError = { fg = c.red },
    DiagnosticVirtualTextWarn  = { fg = c.yellow },
    DiagnosticVirtualTextInfo  = { fg = c.blue },
    DiagnosticVirtualTextHint  = { fg = c.cyan },

    -- ---------- diff / git ----------
    DiffAdd     = { fg = c.green,  bg = "#1f2a24" },
    DiffChange  = { fg = c.yellow, bg = "#262a1f" },
    DiffDelete  = { fg = c.red,    bg = "#2a1f1f" },
    DiffText    = { fg = c.fg,     bg = "#2f3a30" },
    Added       = { fg = c.green },
    Changed     = { fg = c.yellow },
    Removed     = { fg = c.red },
    GitSignsAdd    = { fg = c.green },
    GitSignsChange = { fg = c.yellow },
    GitSignsDelete = { fg = c.red },

    -- ---------- telescope ----------
    TelescopeNormal       = { fg = c.fg_dim, bg = bg },
    TelescopeBorder       = { fg = c.border, bg = bg },
    TelescopePromptNormal = { fg = c.fg, bg = bg },
    TelescopePromptBorder = { fg = c.keyword, bg = bg },
    TelescopePromptTitle  = { fg = c.keyword, bold = true },
    TelescopeResultsTitle = { fg = c.comment },
    TelescopePreviewTitle = { fg = c.green },
    TelescopeSelection    = { fg = c.fg, bg = c.selection, bold = true },
    TelescopeMatching     = { fg = c.func, bold = true },
    TelescopePromptPrefix = { fg = c.func },

    -- ---------- neo-tree ----------
    NeoTreeNormal        = { fg = c.fg_dim, bg = bg_side },
    NeoTreeNormalNC      = { fg = c.fg_dim, bg = bg_side },
    NeoTreeWinSeparator  = { fg = c.border, bg = bg_side },
    NeoTreeEndOfBuffer   = { fg = c.bg_dark, bg = bg_side },
    NeoTreeRootName      = { fg = c.func, bold = true },
    NeoTreeDirectoryName = { fg = c.keyword },
    NeoTreeDirectoryIcon = { fg = c.keyword },
    NeoTreeFileName      = { fg = c.fg_dim },
    NeoTreeFileNameOpened= { fg = c.fg, bold = true },
    NeoTreeCursorLine    = { bg = c.selection },
    NeoTreeIndentMarker  = { fg = c.bg_light },
    NeoTreeGitAdded      = { fg = c.green },
    NeoTreeGitModified   = { fg = c.yellow },
    NeoTreeGitDeleted    = { fg = c.red },
    NeoTreeGitUntracked  = { fg = c.comment },

    -- ---------- blink.cmp ----------
    BlinkCmpMenu          = { fg = c.fg_dim, bg = bg },
    BlinkCmpMenuBorder    = { fg = c.border, bg = bg },
    BlinkCmpMenuSelection = { bg = c.selection, bold = true },
    BlinkCmpLabel         = { fg = c.fg_dim },
    BlinkCmpLabelMatch    = { fg = c.func, bold = true },
    BlinkCmpKind          = { fg = c.cyan },
    BlinkCmpDoc           = { fg = c.fg_dim, bg = bg },
    BlinkCmpDocBorder     = { fg = c.border, bg = bg },
    BlinkCmpSignatureHelp = { fg = c.fg_dim, bg = bg },

    -- ---------- which-key ----------
    WhichKey          = { fg = c.func },
    WhichKeyGroup     = { fg = c.keyword },
    WhichKeyDesc      = { fg = c.fg_dim },
    WhichKeySeparator = { fg = c.comment },
    WhichKeyFloat     = { bg = bg },
    WhichKeyBorder    = { fg = c.border, bg = bg },

    -- ---------- bufferline ----------
    BufferLineFill              = { bg = transparent and "NONE" or c.bg_dark },
    BufferLineBackground        = { fg = c.comment, bg = transparent and "NONE" or c.bg_dark },
    BufferLineBufferSelected    = { fg = c.fg, bg = bg, bold = true },
    BufferLineBufferVisible     = { fg = c.fg_dim, bg = transparent and "NONE" or c.bg_dark },
    BufferLineSeparator         = { fg = c.border, bg = transparent and "NONE" or c.bg_dark },
    BufferLineSeparatorSelected = { fg = c.border, bg = bg },
    BufferLineIndicatorSelected = { fg = c.func, bg = bg },

    -- ---------- render-markdown ----------
    RenderMarkdownH1Bg   = { fg = c.red,    bg = "#2a2028" },
    RenderMarkdownH2Bg   = { fg = c.orange, bg = "#2a2622" },
    RenderMarkdownH3Bg   = { fg = c.yellow, bg = "#282722" },
    RenderMarkdownH4Bg   = { fg = c.green,  bg = "#222822" },
    RenderMarkdownH5Bg   = { fg = c.cyan,   bg = "#1f2a2c" },
    RenderMarkdownH6Bg   = { fg = c.purple, bg = "#262230" },
    RenderMarkdownCode   = { bg = c.bg_light },
    RenderMarkdownBullet = { fg = c.keyword },
    RenderMarkdownQuote  = { fg = c.comment },
    RenderMarkdownDash   = { fg = c.border },
    RenderMarkdownTableHead = { fg = c.keyword },
    RenderMarkdownTableRow  = { fg = c.fg_dim },

    -- ---------- misc plugins ----------
    TreesitterContext       = { bg = c.bg_light },
    TreesitterContextLineNumber = { fg = c.line_nr, bg = c.bg_light },
    AlphaHeader             = { fg = c.keyword },
    AlphaButtons            = { fg = c.func },
    AlphaFooter             = { fg = c.comment, italic = true },
    SnacksIndent            = { fg = c.indent },

    -- commit panel under the file tree (lua/core/gitpanel.lua)
    GitPanelHead            = { fg = c.func, bold = true },
    GitPanelGraph           = { fg = c.indent_scope },
    GitPanelSubject         = { fg = c.fg_dim },
    GitPanelTime            = { fg = c.line_nr },
    GitPanelRef             = { fg = c.keyword, bold = true },

    -- indent-blankline. Set explicitly rather than letting it fall back to
    -- Whitespace, which also drives listchars and should stay near-invisible.
    ["@ibl.indent.char.1"]     = { fg = c.indent },
    ["@ibl.whitespace.char.1"] = { fg = c.indent },
    ["@ibl.scope.char.1"]      = { fg = c.indent_scope },
    ["@ibl.scope.underline.1"] = { fg = c.indent_scope },
    IblIndent                  = { fg = c.indent },
    IblWhitespace              = { fg = c.indent },
    IblScope                   = { fg = c.indent_scope },
  }

  for group, spec in pairs(groups) do hl(group, spec) end

  -- terminal palette, so :terminal matches the theme
  vim.g.terminal_color_0  = c.bg_dark
  vim.g.terminal_color_1  = c.red
  vim.g.terminal_color_2  = c.green
  vim.g.terminal_color_3  = c.yellow
  vim.g.terminal_color_4  = c.blue
  vim.g.terminal_color_5  = c.purple
  vim.g.terminal_color_6  = c.cyan
  vim.g.terminal_color_7  = c.fg_dim
  vim.g.terminal_color_8  = c.comment
  vim.g.terminal_color_9  = c.red
  vim.g.terminal_color_10 = c.green
  vim.g.terminal_color_11 = c.yellow
  vim.g.terminal_color_12 = c.blue
  vim.g.terminal_color_13 = c.purple
  vim.g.terminal_color_14 = c.cyan
  vim.g.terminal_color_15 = c.fg
end

return M
