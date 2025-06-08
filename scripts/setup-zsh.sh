#!/usr/bin/env zsh

# ─────────────────────────────────────────────
# Setup Zsh + Oh My Zsh + Plugins + Default .zshrc
# ─────────────────────────────────────────────

# Define a helper for colored output
log() {
  local color="$1"
  local message="$2"
  case "$color" in
    green) color_code="\033[0;32m" ;;
    blue)  color_code="\033[0;34m" ;;
    red)   color_code="\033[0;31m" ;;
    *)     color_code="" ;;
  esac
  echo -e "${color_code}${message}\033[0m"
}

if [[ -n "$BASH_VERSION" ]]; then
  log red "❌ This script must be run in Zsh"
  log blue "➡️ Run 'exec zsh' then restart"
  exit 1
fi

if [ -z "$ZSH_VERSION" ]; then
  log red "❌ Zsh is not running properly"
  exit 1
fi

# Install Oh My Zsh if needed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log blue "➡️ Installing Oh My Zsh..."
  export RUNZSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log green "✅ Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install plugins
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
  log blue "➡️ Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
else
  log green "✅ zsh-autosuggestions already installed"
fi

if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
  log blue "➡️ Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
else
  log green "✅ zsh-syntax-highlighting already installed"
fi

# Default .zshrc if missing or empty
if [ ! -s "$HOME/.zshrc" ]; then
  log blue "📝 Creating default .zshrc..."
  cat > "$HOME/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Aliases
alias ll='ls -la'
alias gs='git status'
alias ..='cd ..'
alias ...='cd ../..'

# eza
if command -v eza &>/dev/null; then
  alias ls="eza --icons=always --group-directories-first"
  alias tree="eza --tree --icons=always"
  alias l='eza -lbF --git'
  alias la='eza -lbhHigUa --git'
fi

# zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Java
export PATH="/usr/local/opt/openjdk@21/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || echo "/usr/local/opt/openjdk@21")

# PATH
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH"
EOF
  log green "✅ Default .zshrc created"
else
  log blue "➡️ Ensuring plugins are set in .zshrc"
  if grep -q "^plugins=" ~/.zshrc; then
    sed -i '' 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
  else
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> ~/.zshrc
  fi
fi

log blue "🔄 Reloading ~/.zshrc..."
source "$HOME/.zshrc"

log green "✅ Zsh setup complete"
