#!/bin/zsh

# Thanks to https://mths.be/macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed"
fi

# Check if Brewfile exists in the same directory as the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BREWFILE_PATH="$SCRIPT_DIR/Brewfile"

if [ -f "$BREWFILE_PATH" ]; then
  echo "Installing Brewfile packages from $BREWFILE_PATH..."
  brew bundle --no-lock --file="$BREWFILE_PATH"
else
  echo "Brewfile not found in $SCRIPT_DIR. Skipping Brewfile installation."
fi

# Accept Xcode license. This is needed for Oh My Zsh and Powerlevel10k
echo "Accept the license for Xcode with sudo"
sudo xcodebuild -license

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh is already installed"
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "Installing Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
else
  echo "Powerlevel10k theme is already installed"
fi

###############################################################################
# Xcode                                                                       #
###############################################################################
# Configure Xcode settings
echo "Configuring Xcode settings..."
# Many settings from https://github.com/ctreffs/xcode-defaults
# Set custom font (example: Menlo 14)
defaults write com.apple.dt.Xcode XCFontAndColorCurrentPreferenceSet -string "JetBrains Mono Medium 16"
# Enable display of invisible characters
defaults write com.apple.dt.Xcode DVTTextShowInvisibleCharacters 1
# With Xcode 13.3 the build system and Swift compiler have a new mode that better utilizes available cores, resulting in faster builds for Swift projects
defaults write com.apple.dt.XCBuild EnableSwiftBuildSystemIntegration 1
# Enable project build time
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool YES
# Enable parallel builds for Swift
defaults write com.apple.dt.Xcode BuildSystemScheduleInherentlyParallelCommandsExclusively -bool YES
# Enable multi-cursor editing
defaults write com.apple.dt.Xcode PegasusMultipleCursorsEnabled -bool YES
# Set maximum number of concurrent compile tasks
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks `sysctl -n hw.ncpu`
# Set maximum number of parallel build subtasks
defaults write com.apple.dt.Xcode PBXNumberOfParallelBuildSubtasks `sysctl -n hw.ncpu`
# Make Xcode's Assistant aware of your ViewModels, Views, etc.
defaults write com.apple.dt.Xcode IDEAdditionalCounterpartSuffixes -array "ViewModel" "View" "Screen"
# Set screenshots location
defaults write com.apple.iphonesimulator "ScreenShotSaveLocation" -string "~/Pictures/Simulator Screenshots"

###############################################################################
# Finder and Desktop settings                                                 #
###############################################################################

# More settings from https://macos-defaults.com
# Disable screenshot shadow when capturing an app
defaults write com.apple.screencapture "disable-shadow" -bool "true"
# Show hidden files inside the Finder
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"
# Hide all icons
defaults write com.apple.finder "CreateDesktop" -bool "false"
# Show path bar
defaults write com.apple.finder "ShowPathbar" -bool "true"
# Save screenshots to ~/Pictures
defaults write com.apple.screencapture "location" -string "~/Pictures"
# Thu 18 Aug 21:46:18
defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm:ss\""
# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Show the ~/Library folder
chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library
# Show the /Volumes folder
sudo chflags nohidden /Volumes
# Add iOS & Watch Simulator to Launchpad
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"
# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Disable transparency in the menu bar and elsewhere on Yosemite
defaults write com.apple.universalaccess reduceTransparency -bool true

# Set the desktop background to black
osascript -e 'tell application "Finder"
set desktop picture to POSIX file "/System/Library/Desktop Pictures/Solid Colors/Black.png"
end tell'

# # Set Dvorak and US keyboard layouts
# defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
#   '{ "InputSourceKind" = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; }' \
#   '{ "InputSourceKind" = "Keyboard Layout"; "KeyboardLayout ID" = 2; "KeyboardLayout Name" = "Dvorak"; }'

###############################################################################
# Dock                                                                        #
###############################################################################

# Do not display recent apps in the Dock
defaults write com.apple.dock "show-recents" -bool "false"

# Clear the Dock
echo "Clearing the Dock..."
dockutil --remove all --no-restart

# Add Launchpad
echo "Adding Launchpad to the Dock..."
dockutil --add '/Applications/Launchpad.app' --no-restart

# Add Safari
echo "Adding Safari to the Dock..."
dockutil --add '/Applications/Safari.app' --no-restart

# Add System Preferences (Settings)
echo "Adding System Preferences to the Dock..."
dockutil --add '/Applications/System Settings.app' --no-restart

# Add Downloads folder
echo "Adding Downloads folder to the Dock..."
dockutil --add '~/Downloads' --view fan --display stack --sort dateadded --no-restart

###############################################################################
# Actual Dotfiles                                                             #
###############################################################################

# Create symbolic links
create_symlink() {
  local source_file="$1"
  local target_file="$2"
  
  if [ -L "$target_file" ]; then
    echo "Symbolic link for $target_file already exists. Skipping..."
  else
    echo "Creating symbolic link for $target_file..."
    ln -sf "$source_file" "$target_file"
  fi
}

create_symlink "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
create_symlink "$HOME/.dotfiles/.p10k.zsh" "$HOME/.p10k.zsh"
create_symlink "$HOME/.dotfiles/.gitignore_global" "$HOME/.gitignore_global"
create_symlink "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"
create_symlink "$HOME/.dotfiles/.config" "$HOME/.config"

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in \
  "Dock" \
  "Finder" \
  "SystemUIServer" \
  "Xcode" \
  ; do
  killall "${app}" &> /dev/null
done

# Source the .zshrc to apply changes immediately
source ~/.zshrc

echo "Setup complete!"
