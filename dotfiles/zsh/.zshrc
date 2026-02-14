# Basic zsh setup

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory histignorealldups

# --- Zinit ---
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${ZDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Completion
autoload -Uz compinit && compinit
zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{A-Za-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-flags --height=17
zstyle ':fzf-tab:complete:*' fzf-preview '
if [ -d "$realpath" ]; then
    eza --icons --tree --level=2 --color=always "$realpath"
elif [ -f "$realpath" ]; then
    bat -n --color=always --line-range :500 "$realpath"
fi
'

# Keybindings
bindkey -e

# Aliases
alias ls='eza --icons --color=always'
alias ll='eza --icons --color=always -l'
alias la='eza --icons --color=always -a'
alias lla='eza --icons --color=always -la'
alias lt='eza --icons --color=always -a --tree --level=1'
alias grep='grep --color=always'
alias vim='nvim'
alias cbonsai='cbonsai -l -i -w 1'

# Bat (better than cat)
export BAT_THEME="base16"
alias bat='bat --paging=never'

# Zoxide (better than cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# --- FZF ---
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi
# FZF theme catppuccin
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#313244,label:#CDD6F4"
export FZF_TAB_COLORS='fg:#CDD6F4,bg:#1E1E2E,hl:#F38BA8,min-height=5'

# Oh My Posh
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/powerlevel10k_lean.omp.json)"
fi

# Optional local overrides
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
