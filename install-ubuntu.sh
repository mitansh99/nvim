#!/usr/bin/env bash
# =============================================================================
#  Bootstrap this Neovim config on Ubuntu 24.04.
#
#  Safe to re-run: every step checks whether it already did its job.
#  Nothing is removed. Existing configs are backed up with a timestamp.
#
#  Usage:  ./install-ubuntu.sh            everything
#          ./install-ubuntu.sh --no-go    skip the Go toolchain
#          ./install-ubuntu.sh --no-font  skip the Nerd Font
# =============================================================================
set -euo pipefail

NVIM_MIN_MAJOR=0
NVIM_MIN_MINOR=11          # vim.lsp.config landed in 0.11; the config needs it
STAMP="$(date +%Y%m%d-%H%M%S)"
WANT_GO=1
WANT_FONT=1
for a in "$@"; do
  case "$a" in
    --no-go)   WANT_GO=0 ;;
    --no-font) WANT_FONT=0 ;;
    *) echo "unknown flag: $a"; exit 1 ;;
  esac
done

say()  { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
ok()   { printf '    \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '    \033[33m!\033[0m %s\n' "$1"; }

case "$(uname -m)" in
  x86_64)  NVIM_ARCH=linux-x86_64; LG_ARCH=Linux_x86_64; GO_ARCH=amd64; DEB_ARCH=amd64 ;;
  aarch64) NVIM_ARCH=linux-arm64;  LG_ARCH=Linux_arm64;  GO_ARCH=arm64; DEB_ARCH=arm64 ;;
  *) echo "unsupported architecture: $(uname -m)"; exit 1 ;;
esac
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# -----------------------------------------------------------------------------
say "1/8  apt packages"
# build-essential: treesitter compiles every parser from C
# ripgrep: telescope's project-wide text search
# fd-find: fast file finding (Ubuntu names the binary fdfind)
# wl-clipboard + xclip: WITHOUT one of these, clipboard=unnamedplus silently
#                       does nothing. 24.04 defaults to Wayland, X11 is the
#                       fallback, so install both and let nvim pick.
sudo apt-get update -qq
sudo apt-get install -y -qq \
  build-essential git curl wget unzip tar \
  ripgrep fd-find \
  wl-clipboard xclip \
  fontconfig ca-certificates
ok "base packages installed"

if [ ! -e "$HOME/.local/bin/fd" ] && command -v fdfind >/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  ok "linked fdfind -> ~/.local/bin/fd  (Ubuntu renames this binary)"
fi

# -----------------------------------------------------------------------------
say "2/8  Neovim >= ${NVIM_MIN_MAJOR}.${NVIM_MIN_MINOR}"
# Ubuntu 24.04's apt ships Neovim 0.9.5, which is too old: this config calls
# vim.lsp.config, vim.diagnostic.jump and vim.hl.on_yank, all 0.11+.
# The official release tarball avoids PPAs and AppImage/FUSE entirely.
need_nvim=1
if command -v nvim >/dev/null; then
  v=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo 0.0.0)
  maj=${v%%.*}; rest=${v#*.}; min=${rest%%.*}
  if [ "$maj" -gt "$NVIM_MIN_MAJOR" ] || { [ "$maj" -eq "$NVIM_MIN_MAJOR" ] && [ "$min" -ge "$NVIM_MIN_MINOR" ]; }; then
    need_nvim=0; ok "nvim $v already satisfies the minimum"
  else
    warn "nvim $v is too old, installing a current build alongside it"
  fi
fi
if [ "$need_nvim" -eq 1 ]; then
  curl -fL --progress-bar -o "$TMP/nvim.tar.gz" \
    "https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz"
  sudo rm -rf /opt/nvim
  sudo mkdir -p /opt/nvim
  sudo tar -C /opt/nvim --strip-components=1 -xzf "$TMP/nvim.tar.gz"
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  ok "nvim $(/usr/local/bin/nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+') -> /usr/local/bin/nvim"
fi

# -----------------------------------------------------------------------------
say "3/8  Node.js (mason installs the JS/TS servers with it)"
if command -v node >/dev/null && [ "$(node -v | tr -d 'v' | cut -d. -f1)" -ge 18 ]; then
  ok "node $(node -v) already present"
else
  export NVM_DIR="$HOME/.nvm"
  if [ ! -d "$NVM_DIR" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  nvm install --lts
  ok "node $(node -v) via nvm"
fi

# -----------------------------------------------------------------------------
say "4/8  Go toolchain (for gopls)"
if [ "$WANT_GO" -eq 0 ]; then
  warn "skipped (--no-go)"
elif command -v go >/dev/null; then
  ok "go $(go version | awk '{print $3}') already present"
else
  GO_VER=$(curl -fsSL https://go.dev/VERSION?m=text | head -1)
  curl -fL --progress-bar -o "$TMP/go.tar.gz" "https://go.dev/dl/${GO_VER}.linux-${GO_ARCH}.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "$TMP/go.tar.gz"
  ok "$GO_VER -> /usr/local/go"
fi

# -----------------------------------------------------------------------------
say "5/8  lazygit (not packaged in Ubuntu 24.04)"
if command -v lazygit >/dev/null; then
  ok "lazygit $(lazygit --version 2>/dev/null | grep -oE 'version=[^,]*' | cut -d= -f2) already present"
else
  LG_VER=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
           | grep -oE '"tag_name": *"v[^"]+"' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  curl -fL --progress-bar -o "$TMP/lazygit.tar.gz" \
    "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_${LG_ARCH}.tar.gz"
  tar -C "$TMP" -xzf "$TMP/lazygit.tar.gz" lazygit
  sudo install -m 755 "$TMP/lazygit" /usr/local/bin/lazygit
  ok "lazygit ${LG_VER} -> /usr/local/bin/lazygit"
fi

# -----------------------------------------------------------------------------
say "6/8  JetBrainsMono Nerd Font"
# The Ghostty config asks for the family "JetBrainsMono Nerd Font Mono".
# Ghostty matches on FAMILY name, not PostScript name - getting that wrong is
# why the font silently failed on the Mac.
if [ "$WANT_FONT" -eq 0 ]; then
  warn "skipped (--no-font)"
elif fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font Mono"; then
  ok "already installed"
else
  mkdir -p "$HOME/.local/share/fonts/JetBrainsMono"
  curl -fL --progress-bar -o "$TMP/JetBrainsMono.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -oq "$TMP/JetBrainsMono.zip" -d "$HOME/.local/share/fonts/JetBrainsMono"
  fc-cache -f >/dev/null
  if fc-list | grep -qi "JetBrainsMono Nerd Font Mono"; then
    ok "installed and registered"
  else
    warn "font unzipped but fontconfig does not list it - check 'fc-list | grep JetBrains'"
  fi
fi

# -----------------------------------------------------------------------------
say "7/8  Neovim config"
CFG="$HOME/.config/nvim"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$REPO_ROOT" != "$CFG" ]; then
  if [ -e "$CFG" ]; then
    mv "$CFG" "$CFG.backup-$STAMP"
    warn "existing config moved to $CFG.backup-$STAMP"
  fi
  mkdir -p "$(dirname "$CFG")"
  ln -s "$REPO_ROOT" "$CFG"
  ok "linked $REPO_ROOT -> $CFG"
else
  ok "config already lives at $CFG"
fi

# -----------------------------------------------------------------------------
say "8/8  PATH"
LINE_GO='export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"'
LINE_LOCAL='export PATH="$HOME/.local/bin:$PATH"'
RC="$HOME/.bashrc"; [ -n "${ZSH_VERSION:-}" ] && RC="$HOME/.zshrc"
for line in "$LINE_LOCAL" "$LINE_GO"; do
  grep -qxF "$line" "$RC" 2>/dev/null || { echo "$line" >> "$RC"; ok "added to $(basename "$RC"): $line"; }
done

# -----------------------------------------------------------------------------
say "Done. Next:"
cat <<'NEXT'
    1. Open a NEW terminal (so PATH changes apply), then run:  nvim
       lazy.nvim bootstraps itself and installs every plugin.
       Treesitter compiles ~27 parsers - this takes a couple of minutes.

    2. Then, inside nvim:
         :Lazy         watch plugins finish
         :Mason        watch the 17 language servers and formatters install
         :checkhealth  should report no ERRORs

    3. Verify the parts that have bitten us before:
         :lua =vim.fn.has('clipboard')        -> 1   (else yank won't reach the system clipboard)
         :lua =vim.treesitter.language.add('javascript')
         open a .md file                      -> headings should render, not show ###
         open a .jsx file, type useSta        -> useState should offer an auto-import

    4. Terminal: copy ghostty-config from this repo to ~/.config/ghostty/config
NEXT
