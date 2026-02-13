# archbtw

Arch Linux post-install automation for a Wayland setup using:

- `niri`
- `noctalia-shell`
- `ghostty`
- `neovim` + AstroNvim template
- Noctalia-driven dynamic Neovim theming (`base16` + `matugen`)

## What this script does

`setup.sh` performs the following:

1. Installs `paru` (AUR helper) if missing.
2. Installs core packages with `pacman`.
3. Installs `noctalia-shell` from AUR.
4. Backs up existing Neovim state and installs AstroNvim template to `~/.config/nvim`.
5. Adds Noctalia/Matugen integration for dynamic Neovim recoloring.
6. Writes a starter Niri config to `~/.config/niri/config.kdl`.
7. Optionally configures autologin on `tty1` and auto-starts Niri from `~/.bash_profile`.

## Prerequisites

- Fresh Arch install with internet access
- Enable networking with NetworkManager:

```bash
sudo systemctl enable --now NetworkManager
```
- A regular user account with `sudo` access
- Run from user session (not as root)

## Usage

From this repository:

```bash
chmod +x setup.sh
./setup.sh
```

You will be prompted whether to configure autologin + auto-start on `tty1`.

## What gets modified

- `~/.config/nvim` (AstroNvim template + theme integration)
- `~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/nvim` (backed up if present)
- `~/.config/noctalia/user-templates.toml`
- `~/.config/niri/config.kdl`
- `~/.bash_profile` (if autostart is enabled)
- `getty@tty1.service` override (if autologin is enabled)

## Default keybind highlights (Niri config)

- `Super+Return`: open Ghostty
- `Super+E`: open Neovim in Ghostty
- `Super+D`: app launcher (`fuzzel`)
- `Super+Shift+Q`: close focused window

## After running

1. Reboot.
2. Log in (or autologin to `tty1` if enabled).
3. Open Noctalia settings and enable **User Templates**:
	- Color Scheme → Templates → Advanced → Enable User Templates
4. Change Noctalia scheme to trigger Neovim recolor.

## Notes

- Existing Neovim config is moved to `~/.config/nvim.bak` if present.
- The script is intentionally opinionated and overwrites the Niri config file.

## References

- Noctalia Neovim guide: https://docs.noctalia.dev/theming/program-specific/neovim/
- AstroNvim docs: https://docs.astronvim.com/