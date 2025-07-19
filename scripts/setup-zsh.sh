#!/usr/bin/env zsh

# Helper for colored output
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

ZSHRC="$HOME/.zshrc"
ALIAS_FILE="$HOME/.zsh_aliases"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# 1. Ensure Oh My Zsh is installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log blue "➡️ Installing Oh My Zsh..."
  export RUNZSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log green "✅ Oh My Zsh already installed"
fi

# 2. Ensure plugins installed (zsh-autosuggestions, syntax-highlighting)
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

# 3. Create or update ~/.zsh_aliases with all your aliases
cat > "$ALIAS_FILE" <<'EOF'
# Custom aliases managed by setup script

alias ll='ls -la'
alias gs='git status'
alias ..='cd ..'
alias ...='cd ../..'

# eza aliases
if command -v eza &>/dev/null; then
  alias ls="eza --icons=always --group-directories-first"
  alias tree="eza --tree --icons=always"
  alias l='eza -lbF --git'
  alias la='eza -lbhHigUa --git'
fi
EOF

log green "✅ Aliases written to $ALIAS_FILE"

# 4. Ensure .zshrc sources ~/.zsh_aliases if not already done
if ! grep -q "source $ALIAS_FILE" "$ZSHRC"; then
  log blue "➡️ Adding source line for $ALIAS_FILE in $ZSHRC"
  echo "" >> "$ZSHRC"
  echo "# Source custom aliases" >> "$ZSHRC"
  echo "source $ALIAS_FILE" >> "$ZSHRC"
else
  log green "✅ $ZSHRC already sources $ALIAS_FILE"
fi

# 5. Ensure plugins line in .zshrc includes needed plugins (git, zsh-autosuggestions, zsh-syntax-highlighting)
if grep -q "^plugins=" "$ZSHRC"; then
  sed -i '' 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
  log green "✅ Plugins list updated in $ZSHRC"
else
  echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> "$ZSHRC"
  log green "✅ Plugins list added to $ZSHRC"
fi

# 6. Reload .zshrc to apply changes immediately in current session
log blue "🔄 Reloading $ZSHRC"
source "$ZSHRC"

log green "✅ Zsh setup complete"

