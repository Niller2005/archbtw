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
    ttf-jetbrains-mono-nerd

# Noctalia from AUR
echo "Installing noctalia-shell from AUR..."
paru -S --noconfirm --needed noctalia-shell

echo "Packages installed."

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

# Create matugen module (from Noctalia docs)
mkdir -p ~/.config/nvim/lua/matugen
cat > ~/.config/nvim/lua/matugen/init.lua << 'EOF'
local M = {}

function M.setup()
    require('base16-colorscheme').setup {
        -- Background tones
        base00 = '{{colors.surface.default.hex}}', -- Default Background
        base01 = '{{colors.surface_container.default.hex}}', -- Lighter Background (status bars)
        base02 = '{{colors.surface_container_high.default.hex}}', -- Selection Background
        base03 = '{{colors.outline.default.hex}}', -- Comments, Invisibles

        -- Foreground tones
        base04 = '{{colors.on_surface_variant.default.hex}}', -- Dark Foreground (status bars)
        base05 = '{{colors.on_surface.default.hex}}', -- Default Foreground
        base06 = '{{colors.on_surface.default.hex}}', -- Light Foreground
        base07 = '{{colors.on_background.default.hex}}', -- Lightest Foreground

        -- Accent colors
        base08 = '{{colors.error.default.hex}}', -- Variables, XML Tags, Errors
        base09 = '{{colors.tertiary.default.hex}}', -- Integers, Constants
        base0A = '{{colors.secondary.default.hex}}', -- Classes, Search Background
        base0B = '{{colors.primary.default.hex}}', -- Strings, Diff Inserted
        base0C = '{{colors.tertiary_fixed_dim.default.hex}}', -- Regex, Escape Chars
        base0D = '{{colors.primary_fixed_dim.default.hex}}', -- Functions, Methods
        base0E = '{{colors.secondary_fixed_dim.default.hex}}', -- Keywords, Storage
        base0F = '{{colors.error_container.default.hex}}', -- Deprecated, Embedded Tags
    }
end

-- Reload on SIGUSR1 (sent by Noctalia template post-hook)
local signal = vim.uv.new_signal()
signal:start(
    'sigusr1',
    vim.schedule_wrap(function()
        package.loaded['matugen'] = nil
        require('matugen').setup()
        vim.cmd('colorscheme base16')  -- Ensure reload
    end)
)

return M
EOF

# Add to AstroNvim user config (safe append/create)
USER_INIT=~/.config/nvim/lua/user/init.lua
mkdir -p ~/.config/nvim/lua/user

if ! grep -q "require('matugen').setup()" "$USER_INIT" 2>/dev/null; then
    cat >> "$USER_INIT" << 'EOF'

-- Noctalia dynamic theme integration
require('matugen').setup()
vim.cmd('colorscheme base16')  -- or set in AstroCommunity if preferred
EOF
    echo "Added Noctalia theme loader to $USER_INIT"
else
    echo "Noctalia theme loader already in $USER_INIT — skipped"
fi

# Add Noctalia user template for auto-updates
mkdir -p ~/.config/noctalia
cat >> ~/.config/noctalia/user-templates.toml << 'EOF'

[templates.nvim-base16]
input_path = "~/.config/nvim/lua/matugen/init.lua"
output_path = "~/.config/nvim/lua/matugen/generated.lua"  # optional: can symlink or adjust
post_hook = "pkill -SIGUSR1 nvim"
EOF

echo "Noctalia Neovim template added (enable User Templates in Noctalia Settings → Color Scheme → Templates → Advanced)."
echo " → Change color scheme in Noctalia → Neovim auto-updates via SIGUSR1"

# ────────────────────────────────────────────────────────────────────────────────
# 5. Setup Niri config (~/.config/niri/config.kdl)
# ────────────────────────────────────────────────────────────────────────────────
echo "Setting up Niri config..."

mkdir -p ~/.config/niri

niri --config ~/.config/niri/config.kdl >/dev/null 2>&1 || true

cat > ~/.config/niri/config.kdl << 'EOF'
// Basic Niri config with Ghostty + Noctalia
input {
    keyboard {
        xkb {
            layout "us"
        }
    }
    warp-mouse-to-focus false
    focus-follows-mouse false
}

output "eDP-1" {
    scale 1.0
}

cursor {
    xcursor-theme "Adwaita"
    xcursor-size 24
}

spawn-at-startup "noctalia-shell"
spawn-at-startup "mako"
spawn-at-startup "xwayland-satellite"

binds {
    Mod+Return { spawn "ghostty"; }
    Mod+E { spawn "ghostty" "-e" "nvim"; }
    Mod+D { spawn "fuzzel"; }
    Mod+Shift+Q { close; }
    Mod+F { fullscreen; }
    Mod+H { focus-monitor-left; }
    Mod+J { focus-window-down; }
    Mod+K { focus-window-up; }
    Mod+L { focus-monitor-right; }
    Mod+Shift+H { move-window-left; }
    Mod+Shift+J { move-window-down; }
    Mod+Shift+K { move-window-up; }
    Mod+Shift+L { move-window-right; }
    Mod+Shift+L { spawn "swaylock" "-f" "-c" "000000"; }
}
EOF

echo "Niri config updated → Super+E opens Neovim with Noctalia theme"

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