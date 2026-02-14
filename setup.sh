#!/usr/bin/env bash
# Arch Linux post-install script: Niri + Noctalia + Ghostty + Neovim (AstroNvim) + Noctalia theme
# =============================================================
# Run this as your normal user after base Arch install + first boot.
# Assumes: internet working, sudo configured, paru not yet installed.
#
# Now includes: Noctalia dynamic theming for Neovim (base16 + matugen)

set -euo pipefail

echo "=== Starting Arch + Niri + Noctalia + Ghostty + AstroNvim + Noctalia Neovim theme setup ==="

# ────────────────────────────────────────────────────────────────────────────────
# 1. Install paru (AUR helper) if not present
# ────────────────────────────────────────────────────────────────────────────────
if ! command -v paru &> /dev/null; then
    echo "Installing paru..."
    sudo pacman -Syu --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm --needed)
    rm -rf /tmp/paru
fi

# ────────────────────────────────────────────────────────────────────────────────
# 2. Install packages
# ────────────────────────────────────────────────────────────────────────────────
echo "Installing core packages..."

sudo pacman -Syu --noconfirm --needed \
    base-devel \
    git \
    coreutils \
    curl \
    unzip \
    stow \
    oh-my-posh \
    fzf \
    eza \
    bat \
    zoxide \
    cbonsai \
    ripgrep \
    tree-sitter \
    lazygit \
    bottom \
    nodejs \
    bun \
    go \
    python \
    zsh \
    niri \
    ghostty \
    neovim \
    xorg-xwayland \
    xwayland-satellite \
    fuzzel \
    mako \
    swayidle \
    swaylock \
    brightnessctl \
    wl-clipboard \
    pipewire \
    pipewire-pulse \
    wireplumber \
    qt5-wayland \
    qt6-wayland \
    ttf-jetbrains-mono-nerd \
    ttf-meslo-nerd

# Noctalia from AUR
echo "Installing noctalia-shell from AUR..."
paru -S --noconfirm --needed noctalia-shell

echo "Packages installed."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
STOW_TARGET="$HOME"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Missing dotfiles directory at $DOTFILES_DIR"
    exit 1
fi

# ────────────────────────────────────────────────────────────────────────────────
# 2.1 Set zsh as default shell if needed
# ────────────────────────────────────────────────────────────────────────────────
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(command -v zsh)" "$USER"
fi

# ────────────────────────────────────────────────────────────────────────────────
# 2.2 Oh My Posh (powerlevel10k_lean) for zsh
# ────────────────────────────────────────────────────────────────────────────────
echo "Setting up Oh My Posh theme..."

# ────────────────────────────────────────────────────────────────────────────────
# 3. Install AstroNvim (using official template)
# ────────────────────────────────────────────────────────────────────────────────
echo "Setting up Neovim + AstroNvim..."

if [ -d ~/.config/nvim ]; then
    echo "Backing up existing ~/.config/nvim to ~/.config/nvim.bak"
    mv ~/.config/nvim ~/.config/nvim.bak
fi

[ -d ~/.local/share/nvim ] && mv ~/.local/share/nvim ~/.local/share/nvim.bak || true
[ -d ~/.local/state/nvim ] && mv ~/.local/state/nvim ~/.local/state/nvim.bak || true
[ -d ~/.cache/nvim ]       && mv ~/.cache/nvim       ~/.cache/nvim.bak       || true

git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
(cd ~/.config/nvim && git remote remove origin)

echo "AstroNvim installed."

# ────────────────────────────────────────────────────────────────────────────────
# 4. Add Noctalia Neovim theming (base16-nvim + matugen integration)
# ────────────────────────────────────────────────────────────────────────────────
echo "Adding Noctalia dynamic theme support to Neovim..."

echo "Noctalia Neovim template ready (enable User Templates in Noctalia Settings → Color Scheme → Templates → Advanced)."
echo " → Change color scheme in Noctalia → Neovim auto-updates via SIGUSR1"

# ────────────────────────────────────────────────────────────────────────────────
# 5. Setup Niri config (~/.config/niri/config.kdl)
# ────────────────────────────────────────────────────────────────────────────────
echo "Setting up Niri config..."
niri --config ~/.config/niri/config.kdl >/dev/null 2>&1 || true
echo "Niri config updated → Super+E opens Neovim with Noctalia theme"

# ────────────────────────────────────────────────────────────────────────────────
# 5.1 Stow configs into place
# ────────────────────────────────────────────────────────────────────────────────
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "$target.bak.$(date +%s)"
    fi
}

backup_if_exists "$HOME/.config/nvim/lua/matugen/init.lua"
backup_if_exists "$HOME/.config/nvim/lua/user/init.lua"
backup_if_exists "$HOME/.config/noctalia/user-templates.toml"
backup_if_exists "$HOME/.config/niri/config.kdl"
backup_if_exists "$HOME/.config/oh-my-posh/powerlevel10k_lean.omp.json"
backup_if_exists "$HOME/.zshrc"

stow -d "$DOTFILES_DIR" -t "$STOW_TARGET" nvim niri noctalia oh-my-posh zsh

# ────────────────────────────────────────────────────────────────────────────────
# 6. Optional: Auto-start Niri from tty1
# ────────────────────────────────────────────────────────────────────────────────
read -p "Set up autologin + auto-start Niri on tty1? (y/N): " autologin
if [[ "$autologin" =~ ^[Yy]$ ]]; then
    read -p "Enter your username for autologin: " username
    if [[ -n "$username" ]]; then
        sudo systemctl edit getty@tty1.service << EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $username --noclear %I \$TERM
EOF

        cat >> ~/.bash_profile << 'EOF'
if [[ -z "$DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
    exec niri
fi
EOF
        echo "Autologin + Niri auto-start set."
    fi
fi

# ────────────────────────────────────────────────────────────────────────────────
# Finish
# ────────────────────────────────────────────────────────────────────────────────
echo ""
echo "Setup complete! 🎉"
echo ""
echo "Next steps:"
echo "  1. Reboot: reboot"
echo "  2. Log in → Niri + Noctalia starts"
echo "  3. Super+Return → Ghostty"
echo "  4. Super+E     → Neovim (AstroNvim + Noctalia theme)"
echo "  5. In Noctalia Settings:"
echo "     → Color Scheme → Templates → Advanced → Enable User Templates"
echo "     → Change scheme → Neovim reloads automatically!"
echo ""
echo "Customize:"
echo "  AstroNvim user config:   ~/.config/nvim/lua/user/"
echo "  Noctalia templates:      ~/.config/noctalia/user-templates.toml"
echo ""
echo "Links:"
echo "  Noctalia Neovim guide:  https://docs.noctalia.dev/theming/program-specific/neovim/"
echo "  AstroNvim docs:         https://docs.astronvim.com/"
echo ""
echo "Enjoy your matched Noctalia-themed Neovim! 🌙"