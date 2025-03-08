# Show hidden files in the Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# --------------------Dock-----------------------------------
# Set the icon size of Dock items in pixels
defaults write com.apple.dock "tilesize" -int "30"

# Autohide
defaults write com.apple.dock "autohide" -bool "true"

# Do not display recent apps in the Dock
defaults write com.apple.dock "show-recents" -bool "false"

# --------------------Finder----------------------------------
# Show all file extensions inside the Finder
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# restart the dock and the finder
killall Dock
killall Finder

echo "MacOS defaults settings was successfully executed !"
