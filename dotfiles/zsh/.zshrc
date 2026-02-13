# Basic zsh setup

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory histignorealldups

# Completion
autoload -Uz compinit && compinit

# Keybindings
bindkey -e

# Oh My Posh
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/powerlevel10k_lean.omp.json)"
fi

# Optional local overrides
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
