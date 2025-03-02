export ZSH="$HOME/.oh-my-zsh"

# Thème Zsh
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Charger Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Alias personnalisés
alias ll='ls -la'
alias gs='git status'

# Ajouter des chemins personnalisés
export PATH="$HOME/bin:$PATH"

# Zoxide
eval "$(zoxide init zsh)"

# ---- Eza (better ls) -----
alias ls="eza --icons=always"
export PATH="/usr/local/opt/openjdk@21/bin:$PATH"
export JAVA_HOME=$(/usr/libexec/java_home)
