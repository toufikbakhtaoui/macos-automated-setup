#!/bin/bash

# ─────────────────────────────────────────────
# macOS Defaults Configuration
# Author: Toufik Bakhtaoui
# https://github.com/toufikbakhtaoui/dotfiles
# ─────────────────────────────────────────────

# Colors
GREEN="\033[0;32m"
NC="\033[0m" # No Color

# ─────────────────────────────────────────────
# Finder Settings
# ─────────────────────────────────────────────
echo -e "${GREEN}⚙️ Configuring Finder...${NC}"
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ─────────────────────────────────────────────
# Dock Settings
# ─────────────────────────────────────────────
echo -e "${GREEN}⚙️ Configuring Dock...${NC}"
defaults write com.apple.dock tilesize -int 30
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false

# ─────────────────────────────────────────────
# Touch ID for sudo
# ─────────────────────────────────────────────
echo -e "${GREEN}⚙️ Enabling Touch ID for sudo...${NC}"
if ! grep -q "pam_tid.so" /etc/pam.d/sudo; then
  sudo sed -i '' '1a\
auth       sufficient     pam_tid.so\
  ' /etc/pam.d/sudo
  echo "Touch ID for sudo successfully enabled!"
else
  echo "Touch ID for sudo was already configured."
fi

# ─────────────────────────────────────────────
# Night Shift Settings
# ─────────────────────────────────────────────
echo -e "${GREEN}🌙 Configuring Night Shift...${NC}"
sudo defaults write com.apple.corebrightnessd "allow-all" -bool true
sudo defaults write com.apple.corebrightnessd "sunset-enabled" -bool true
sudo defaults write com.apple.corebrightnessd "sunset-start" -string "00:00"
sudo defaults write com.apple.corebrightnessd "sunset-end" -string "23:59"
sudo defaults write com.apple.corebrightnessd "transition-speed" -int 0

echo -e "${GREEN}✓ Night Shift configured to always stay on!${NC}"

# ─────────────────────────────────────────────
# Bluetooth Menu Bar Icon
# ─────────────────────────────────────────────
echo -e "${GREEN}📶 Configuring Bluetooth menu bar icon...${NC}"
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.bluetooth" -bool true
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"
# Rebuild the menu bar
killall SystemUIServer

echo -e "${GREEN}✓ Bluetooth icon will now appear in menu bar!${NC}"

# ─────────────────────────────────────────────
# Restart Services
# ─────────────────────────────────────────────
echo -e "${GREEN}♻️ Restarting system services...${NC}"
killall Dock
killall Finder

echo -e "${GREEN}✅ macOS defaults were successfully configured!${NC}"
