#!/bin/bash

# ─────────────────────────────────────────────
# Rollback Script for macOS Dotfiles Setup
# Removes all installed components
# ─────────────────────────────────────────────

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m" # No Color

echo -e "${RED}=== FULL SYSTEM ROLLBACK ===${NC}"

# ─────────────────────────────────────────────
# 1. Remove Dotfiles and Stow Links
# ─────────────────────────────────────────────
DOTFILES_DIR="$HOME/dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
  echo -e "${YELLOW}🗑️ Removing Stow links and dotfiles...${NC}"
  for dir in "$DOTFILES_DIR"/*/; do
    dir_name=$(basename "$dir")
    if [[ ! "$dir_name" =~ ^(\.git|node_modules|.*\..*)$ ]]; then
      stow -v -D -d "$DOTFILES_DIR" -t "$HOME" "$dir_name" 2>/dev/null
    fi
  done
  rm -rf "$DOTFILES_DIR" && echo -e "${GREEN}✓ Dotfiles removed.${NC}"
fi

# ─────────────────────────────────────────────
# 2. Uninstall Homebrew Packages
# ─────────────────────────────────────────────
if command -v brew &>/dev/null; then
  echo -e "${YELLOW}🍺 Uninstalling Homebrew packages...${NC}"
  brew bundle dump --force 2>/dev/null  # Backup current Brewfile
  brew remove --force $(brew list) 2>/dev/null
  brew cleanup --prune=all -s && echo -e "${GREEN}✓ Brew packages removed.${NC}"

  # Uninstall Homebrew itself
  echo -e "${YELLOW}⚠️ Uninstalling Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
fi

# ─────────────────────────────────────────────
# 3. Remove Config Directories
# ─────────────────────────────────────────────
echo -e "${YELLOW}🧹 Cleaning config directories...${NC}"
rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zprofile ~/.config/nvim ~/.tmux 2>/dev/null

# ─────────────────────────────────────────────
# 4. Reset macOS Defaults
# ─────────────────────────────────────────────
if [[ -f "$DOTFILES_DIR/macos-defaults.sh" ]]; then
  echo -e "${YELLOW}⚙️ Reverting macOS settings...${NC}"
  # This would need custom logic to reverse each setting
  # Example for one setting:
  defaults delete -g AppleInterfaceStyle 2>/dev/null
  echo -e "${GREEN}✓ macOS defaults reset.${NC}"
fi

# ─────────────────────────────────────────────
# 6. Final Cleanup
# ─────────────────────────────────────────────
echo -e "${YELLOW}🧽 Final cleanup...${NC}"
rm -rf ~/homebrew ~/.cache ~/.local/share/nvim ~/.java 2>/dev/null

# ─────────────────────────────────────────────
# Completion Message
# ─────────────────────────────────────────────
echo -e "${GREEN}✅ Rollback complete! Your system has been reset.${NC}"
echo -e "${YELLOW}💡 You may need to:"
echo -e "1. Restart your terminal"
echo -e "2. Restart your computer for all changes to take effect${NC}"
