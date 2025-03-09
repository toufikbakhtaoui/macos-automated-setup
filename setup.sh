#!/bin/bash

# Colors for messages
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo -e "${BLUE}=== Automated macOS Installation and Configuration ===${NC}"

# Fixed git repository URL for dotfiles
REPO_URL="https://github.com/toufikbakhtaoui/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Clone the dotfiles git repository
echo -e "${BLUE}Cloning dotfiles repository from $REPO_URL...${NC}"
git clone "$REPO_URL" "$DOTFILES_DIR" || {
  echo -e "${RED}Error cloning repository.${NC}"
  exit 1
}

# Move to the dotfiles directory
cd "$DOTFILES_DIR"

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo -e "${BLUE}Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Add Homebrew to PATH permanently based on the shell being used
  if [[ "$SHELL" == */zsh ]]; then
    echo -e 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
  else
    echo -e 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.bash_profile"
  fi
else
  echo -e "${GREEN}Homebrew is already installed.${NC}"
fi

# Install packages via Homebrew
echo -e "${BLUE}Installing applications from Brewfile...${NC}"
brew bundle || {
  echo -e "${RED}Error installing applications.${NC}"
  exit 1
}

# Install GNU Stow if not present
if ! command -v stow &>/dev/null; then
  echo -e "${BLUE}Installing GNU Stow...${NC}"
  brew install stow
fi

# Apply macOS system configurations
echo -e "${BLUE}Applying macOS settings...${NC}"
chmod +x "$DOTFILES_DIR/macos-defaults.sh"
"$DOTFILES_DIR/macos-defaults.sh" || {
  echo -e "${RED}Error applying macOS settings.${NC}"
  exit 1
}

# Deploy dotfiles with Stow
echo -e "${BLUE}Deploying dotfiles with Stow...${NC}"

# Discover and store all directories that are not hidden and are not files
STOW_PACKAGES=()
for dir in "$DOTFILES_DIR"/*/; do
  dir_name=$(basename "$dir")
  # Exclude hidden or special directories
  if [[ ! "$dir_name" == .* ]] && [[ "$dir_name" != "node_modules" ]] && [[ "$dir_name" != ".git" ]]; then
    STOW_PACKAGES+=("$dir_name")
  fi
done

# If no package is found
if [ ${#STOW_PACKAGES[@]} -eq 0 ]; then
  echo -e "${RED}No directory for Stow was found.${NC}"
  exit 1
fi

# Apply Stow to all packages
for package in "${STOW_PACKAGES[@]}"; do
  echo -e "${GREEN}Deploying dotfiles for: $package${NC}"
  stow -v --restow -d "$DOTFILES_DIR" -t "$HOME" "$package" || { echo "${RED}Error deploying $package.${NC}"; }
done

# Install LazyVim after stowing nvim configuration
echo -e "${BLUE}Installing LazyVim...${NC}"
# Clone LazyVim starter configuration
git clone https://github.com/LazyVim/starter "$DOTFILES_DIR/nvim/.config/nvim"
# Remove the .git directory to avoid conflicts with user's own git repo
rm -rf "$DOTFILES_DIR/nvim/.config/nvim/.git"
echo -e "${GREEN}LazyVim installed successfully!${NC}"

# Install TPM (Tmux Plugin Manager)
echo -e "${BLUE}Installing Tmux plugins manager...${NC}"
git clone https://github.com/tmux-plugins/tpm "$DOTFILES_DIR/tmux/plugins/tpm"
rm -rf "$DOTFILES_DIR/tmux/plugins/tpm/.git"
echo -e "${GREEN}Tmux plugins manager installed successfully!${NC}"

# Reload shell configuration
echo -e "${BLUE}Reloading your shell to apply changes...${NC}"
if [[ -f ~/.zshrc ]]; then
  source ~/.zshrc 2>/dev/null || echo "${RED}Unable to reload ~/.zshrc${NC}"
elif [[ -f ~/.bashrc ]]; then
  source ~/.bashrc 2>/dev/null || echo "${RED}Unable to reload ~/.bashrc${NC}"
fi

echo -e "${GREEN}=== Installation completed successfully! ===${NC}"
echo -e "${GREEN}Your macOS is configured with all your settings and applications.${NC}"
echo -e "${BLUE}Note: Some changes may require a restart to be applied.${NC}"
