# show hidden files in the finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# restart the dock and the finder
killall Dock
killall Finder
