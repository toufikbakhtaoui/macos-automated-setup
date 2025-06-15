#!/usr/bin/env zsh

# ─────────────────────────────────────────────
# Dotfiles macOS Bootstrap Script (Zsh version)
# Author: Toufik Bakhtaoui
# Repo: https://github.com/toufikbakhtaoui/dotfiles
# ─────────────────────────────────────────────

# Colors
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo "${BLUE}=== Automated macOS Installation and Configuration ===${NC}"

# ─────────────────────────────────────────────
# Keep sudo alive
# ─────────────────────────────────────────────
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ─────────────────────────────────────────────
# Prerequisites
# ─────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  echo "${BLUE}🔧 Installing Xcode Command Line Tools...${NC}"
  xcode-select --install
  echo "${RED}⚠️ Please install the tools from the popup, then re-run this script.${NC}"
  exit 1
fi

if ! dscl . -read /Groups/admin GroupMembership | grep -q "\b$USER\b"; then
  echo "${RED}❌ User '$USER' is not admin. Add with:${NC}"
  echo "   sudo dseditgroup -o edit -a $USER -t user admin"
  exit 1
fi

# ─────────────────────────────────────────────
# Homebrew installation
# ─────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "${BLUE}📦 Installing Homebrew...${NC}"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
  fi
else
  echo "${GREEN}✅ Homebrew is already installed.${NC}"
  eval "$(brew shellenv)"
fi

# ─────────────────────────────────────────────
# Clone dotfiles
# ─────────────────────────────────────────────
REPO_URL="git@github.com:toufikbakhtaoui/macos-automated-setup.git"
DOTFILES_DIR="$HOME/macos-automated-setup"

if [[ -d "$DOTFILES_DIR/.git" ]]; then
  echo "${BLUE}🔁 Updating existing dotfiles...${NC}"
  cd "$DOTFILES_DIR" && git pull
else
  echo "${BLUE}📥 Cloning dotfiles...${NC}"
  git clone "$REPO_URL" "$DOTFILES_DIR" || {
    echo "${RED}❌ Failed to clone dotfiles.${NC}"
    exit 1
  }
fi
cd "$DOTFILES_DIR"

# ─────────────────────────────────────────────
# Install from Brewfile
# ─────────────────────────────────────────────
if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
  echo "${BLUE}📦 Installing packages from Brewfile...${NC}"
  brew bundle --file="$DOTFILES_DIR/Brewfile" || {
    echo "${RED}❌ Brew bundle failed.${NC}"
    exit 1
  }
else
  echo "${RED}❌ Brewfile not found.${NC}"
fi

# ─────────────────────────────────────────────
# Clean up existing stow links
# ─────────────────────────────────────────────
echo "${BLUE}🧹 Cleaning up existing stow links...${NC}"
  
  for dir in "$DOTFILES_DIR/dotfiles"/*/; do
    dir_name=$(basename "$dir")
    [[ "$dir_name" =~ ^(\.|.git|node_modules)$ ]] && continue
    
    echo "${BLUE}  → Unstowing: $dir_name${NC}"
    stow -v --delete -d "$DOTFILES_DIR/dotfiles" -t "$HOME" "$dir_name" 2>/dev/null || true
  done

# ===================================================
# Deploy dotfiles using GNU Stow
# ===================================================
echo -e "${BLUE}🔗 Deploying dotfiles using Stow...${NC}"

STOW_PACKAGES=()
for dir in "$DOTFILES_DIR/dotfiles"/*/; do
  dir_name=$(basename "$dir")
  [[ "$dir_name" =~ ^(\.|.git|node_modules)$ ]] && continue
  STOW_PACKAGES+=("$dir_name")
done

if [[ ${#STOW_PACKAGES[@]} -eq 0 ]]; then
  echo -e "${RED}❌ No directories found for stow.${NC}"
  exit 1
fi

for package in "${STOW_PACKAGES[@]}"; do
  echo -e "${GREEN}→ Stowing: $package${NC}"
  stow -v --restow --adopt -d "$DOTFILES_DIR/dotfiles" -t "$HOME" "$package" || {
    echo -e "${RED}❌ Error while stowing $package${NC}"
  }
done

# ─────────────────────────────────────────────
# macOS defaults
# ─────────────────────────────────────────────
if [[ -f "$DOTFILES_DIR/scripts/macos-defaults.sh" ]]; then
  echo "${BLUE}⚙️ Applying macOS defaults...${NC}"
  zsh "$DOTFILES_DIR/scripts/macos-defaults.sh"
fi

# ─────────────────────────────────────────────
# LazyVim
# ─────────────────────────────────────────────
echo "${BLUE}🧠 Installing LazyVim config...${NC}"
git clone https://github.com/LazyVim/starter "$DOTFILES_DIR/dotfiles/nvim/.config/nvim"
rm -rf "$DOTFILES_DIR/dotfiles/nvim/.config/nvim/.git"

# ─────────────────────────────────────────────
# TPM (Tmux Plugin Manager)
# ─────────────────────────────────────────────
echo "${BLUE}🔌 Installing TPM...${NC}"
git clone https://github.com/tmux-plugins/tpm "$DOTFILES_DIR/dotfiles/tmux/plugins/tpm"
rm -rf "$DOTFILES_DIR/dotfiles/tmux/plugins/tpm/.git"

# ─────────────────────────────────────────────
# Zsh setup
# ─────────────────────────────────────────────
echo "${BLUE}⚙️ Applying Zsh settings...${NC}"
zsh "$DOTFILES_DIR/scripts/setup-zsh.sh" || {
  echo "${RED}❌ Error applying Zsh settings.${NC}"
}

# ─────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────
echo "${GREEN}✅ Setup complete. Restart terminal or macOS to apply changes.${NC}"
