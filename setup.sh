#!/bin/bash

# ============================
# Colors for terminal messages
# ============================
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${BLUE}=== Automated macOS Installation and Configuration ===${NC}"

# ===================================================
# Ensure Xcode Command Line Tools are installed
# ===================================================
if ! xcode-select -p &>/dev/null; then
  echo -e "${BLUE}🔧 Xcode Command Line Tools not found. Installing...${NC}"
  xcode-select --install

  echo -e "${BLUE}⏳ Waiting for Command Line Tools installation to complete...${NC}"
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  echo -e "${GREEN}✅ Command Line Tools installed.${NC}"
else
  echo -e "${GREEN}✅ Command Line Tools already installed.${NC}"
fi

# ===================================================
# Clone the dotfiles repository
# ===================================================
REPO_URL="git@github.com:toufikbakhtaoui/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

if [[ -d "$DOTFILES_DIR" ]]; then
  echo -e "${GREEN}✅ Dotfiles directory already exists. Skipping clone.${NC}"
else
  echo -e "${BLUE}📦 Cloning dotfiles from $REPO_URL...${NC}"
  git clone "$REPO_URL" "$DOTFILES_DIR" || {
    echo -e "${RED}❌ Failed to clone dotfiles repo. Check SSH access.${NC}"
    exit 1
  }
fi

cd "$DOTFILES_DIR" || { echo -e "${RED}❌ Cannot access dotfiles directory.${NC}"; exit 1; }

# ===================================================
# Install Homebrew
# ===================================================
if ! command -v brew &>/dev/null; then
  echo -e "${BLUE}📦 Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  eval "$(/opt/homebrew/bin/brew shellenv)"
  [[ "$SHELL" == */zsh ]] && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  [[ "$SHELL" == */bash ]] && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.bash_profile"
else
  echo -e "${GREEN}✅ Homebrew is already installed.${NC}"
fi

# ===================================================
# Install applications from Brewfile
# ===================================================
echo -e "${BLUE}📦 Installing packages from Brewfile...${NC}"
brew bundle || {
  echo -e "${RED}❌ Failed to install Brewfile packages.${NC}"
  exit 1
}

# ===================================================
# Ensure GNU Stow is installed
# ===================================================
if ! command -v stow &>/dev/null; then
  echo -e "${BLUE}📦 Installing GNU Stow...${NC}"
  brew install stow
else
  echo -e "${GREEN}✅ GNU Stow is already installed.${NC}"
fi

# ===================================================
# Apply macOS system preferences
# ===================================================
echo -e "${BLUE}🛠️ Applying macOS system defaults...${NC}"
chmod +x "$DOTFILES_DIR/macos-defaults.sh"
"$DOTFILES_DIR/macos-defaults.sh" || {
  echo -e "${RED}❌ Failed to apply macOS settings.${NC}"
  exit 1
}

# ===================================================
# Deploy dotfiles using GNU Stow
# ===================================================
echo -e "${BLUE}🔗 Deploying dotfiles using Stow...${NC}"

STOW_PACKAGES=()
for dir in "$DOTFILES_DIR"/*/; do
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
  stow -v --restow -d "$DOTFILES_DIR" -t "$HOME" "$package" || {
    echo -e "${RED}❌ Error while stowing $package${NC}"
  }
done

# ===================================================
# Install LazyVim after stowing nvim config
# ===================================================
echo -e "${BLUE}⚙️ Installing LazyVim configuration...${NC}"
git clone https://github.com/LazyVim/starter "$DOTFILES_DIR/nvim/.config/nvim"
rm -rf "$DOTFILES_DIR/nvim/.config/nvim/.git"
echo -e "${GREEN}✅ LazyVim installed.${NC}"

# ===================================================
# Install Tmux Plugin Manager (TPM)
# ===================================================
echo -e "${BLUE}⚙️ Installing Tmux Plugin Manager (TPM)...${NC}"
git clone https://github.com/tmux-plugins/tpm "$DOTFILES_DIR/tmux/plugins/tpm"
rm -rf "$DOTFILES_DIR/tmux/plugins/tpm/.git"
echo -e "${GREEN}✅ TPM installed.${NC}"

# ===================================================
# Reload the shell config
# ===================================================
echo -e "${BLUE}🔄 Reloading shell configuration...${NC}"
if [[ -f "$HOME/.zshrc" ]]; then
  source "$HOME/.zshrc" || echo -e "${RED}⚠️ Failed to source .zshrc${NC}"
elif [[ -f "$HOME/.bashrc" ]]; then
  source "$HOME/.bashrc" || echo -e "${RED}⚠️ Failed to source .bashrc${NC}"
fi

# ===================================================
# Done!
# ===================================================
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo -e "${BLUE}📝 Your system is now configured with your dotfiles and tools.${NC}"
echo -e "${BLUE}🔁 You may want to restart your terminal or your Mac to finalize some settings.${NC}"
