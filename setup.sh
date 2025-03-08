#!/bin/bash
set -e

# Colors for messages
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

echo "${BLUE}=== Automated macOS Installation and Configuration ===${NC}"

# Fixed git repository URL for dotfiles
REPO_URL="https://github.com/toufikbakhtaoui/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Clone the dotfiles git repository
echo "${BLUE}Cloning dotfiles repository from $REPO_URL...${NC}"
git clone "$REPO_URL" "$DOTFILES_DIR" || {
  echo "${RED}Error cloning repository.${NC}"
  exit 1
}

# Move to the dotfiles directory
cd "$DOTFILES_DIR"

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "${BLUE}Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Add Homebrew to PATH permanently based on the shell being used
  if [[ "$SHELL" == */zsh ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.zprofile"
  else
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>"$HOME/.bash_profile"
  fi
else
  echo "${GREEN}Homebrew is already installed.${NC}"
fi

# Install packages via Homebrew
echo "${BLUE}Installing applications from Brewfile...${NC}"
brew bundle || {
  echo "${RED}Error installing applications.${NC}"
  exit 1
}

# Install GNU Stow if not present
if ! command -v stow &>/dev/null; then
  echo "${BLUE}Installing GNU Stow...${NC}"
  brew install stow
fi

# Apply macOS system configurations
echo "${BLUE}Applying macOS settings...${NC}"
chmod +x "$DOTFILES_DIR/macos-defaults.sh"
"$DOTFILES_DIR/macos-defaults.sh" || {
  echo "${RED}Error applying macOS settings.${NC}"
  exit 1
}

# Deploy dotfiles with Stow
echo "${BLUE}Deploying dotfiles with Stow...${NC}"

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
  echo "${RED}No directory for Stow was found.${NC}"
  exit 1
fi

# Apply Stow to all packages
for package in "${STOW_PACKAGES[@]}"; do
  echo "  ${GREEN}Deploying dotfiles for: $package${NC}"
  stow -v --restow -d "$DOTFILES_DIR" -t "$HOME" "$package" || { echo "${RED}Error deploying $package.${NC}"; }
done

# Reload shell configuration
echo "${BLUE}Reloading your shell to apply changes...${NC}"
if [[ -f ~/.zshrc ]]; then
  source ~/.zshrc 2>/dev/null || echo "${RED}Unable to reload ~/.zshrc${NC}"
elif [[ -f ~/.bashrc ]]; then
  source ~/.bashrc 2>/dev/null || echo "${RED}Unable to reload ~/.bashrc${NC}"
fi

echo "${GREEN}=== Installation completed successfully! ===${NC}"
echo "${GREEN}Your macOS is configured with all your settings and applications.${NC}"
echo "${BLUE}Note: Some changes may require a restart to be applied.${NC}"
