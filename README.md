# macOS Dotfiles

This repository contains my dotfiles and configurations for macOS. It's designed to enable a quick and automated setup on a new system.

## Contents

- **Dotfiles**: Configurations for various applications
- **Brewfile**: List of applications to install via Homebrew
- **macos-defaults.sh**: Custom macOS system settings
- **install.sh**: Automated installation script

## Quick Installation

To install the complete configuration on a new macOS system, simply run the following command in Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/toufikbakhtaoui/dotfiles/main/bootstrap.sh | bash
```

This command will download and execute the bootstrap script which:
1. Clones this dotfiles repository
2. Installs Homebrew
3. Installs all applications defined in the Brewfile
4. Configures macOS system settings
5. Deploys dotfiles using GNU Stow

## Manual Installation

If you prefer to proceed step by step, here's how:

1. Clone the repository:
   ```bash
   git clone https://github.com/toufikbakhtaoui/dotfiles.git ~/dotfiles
   ```

2. Install Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. Install applications via Homebrew:
   ```bash
   cd ~/dotfiles
   brew bundle
   ```

4. Apply macOS system settings:
   ```bash
   chmod +x ~/dotfiles/macos-defaults.sh
   ~/dotfiles/macos-defaults.sh
   ```

5. Deploy dotfiles with GNU Stow:
   ```bash
   brew install stow
   cd ~/dotfiles
   # For each configuration folder
   stow zsh tmux vim # etc.
   ```

## Dotfiles Structure

```
~/dotfiles/
├── zsh/               # ZSH configuration
├── vim/               # Vim/Neovim configuration
├── tmux/              # Tmux configuration
├── ...
├── Brewfile           # Homebrew applications list
├── macos-defaults.sh  # macOS system settings
├── install.sh         # Automated installation script
└── bootstrap.sh       # Bootstrap script
```

## Customization

To add or modify configurations:

1. Add or edit files in the corresponding folder
2. For Homebrew applications, modify the `Brewfile`
3. For system settings, modify the `macos-defaults.sh` file

## GNU Stow

This project uses [GNU Stow](https://www.gnu.org/software/stow/) to manage dotfiles and create symbolic links.

Example usage:
```bash
cd ~/dotfiles
stow zsh  # Creates symbolic links for files in ~/dotfiles/zsh/
```

## Maintenance

To update your configuration:

1. Pull the latest changes from the repository:
   ```bash
   cd ~/dotfiles
   git pull
   ```

2. Reapply configurations:
   ```bash
   ./install.sh
   ```

## Notes

- Some system settings may require a restart to be applied
- It's recommended to check the contents of the macos-defaults.sh script before running it to ensure the settings suit your needs
