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
5. Stows repo-managed dotfiles into `~` (Niri, Noctalia, Neovim, Oh My Posh, Zsh).
6. Adds Noctalia/Matugen integration for dynamic Neovim recoloring.
7. Writes a starter Niri config to `~/.config/niri/config.kdl` (via stow).
8. Optionally configures autologin on `tty1` and auto-starts Niri from `~/.bash_profile`.

## Prerequisites

- Fresh Arch install with internet access
- Enable networking with NetworkManager:

```bash
sudo systemctl enable --now NetworkManager
```
- A regular user account with `sudo` access
- Run from user session (not as root)

## Arch install outline (very condensed)

If you need to install Arch itself, follow the official guide for the full, up-to-date procedure. Below is a *minimal outline* for reference only:

1. Boot the Arch ISO and connect to the internet.
2. Partition and format disks (EFI + root at minimum).
3. Mount filesystems under `/mnt`.
4. Install base system:

```bash
pacstrap -K /mnt base linux linux-firmware networkmanager sudo git
```

5. Generate fstab and chroot:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

6. Set timezone, locale, hostname, and root password.
7. Enable `NetworkManager` and install a bootloader (systemd-boot or GRUB).
8. Create a normal user and add them to `wheel`, enable sudo, then reboot.

For complete steps and troubleshooting, use the official install guide:
https://wiki.archlinux.org/title/Installation_guide

## Fresh Arch install (quick run-through)

This script is meant to be run *after* a base Arch install and first boot. If you are starting from scratch, a minimal checklist looks like this:

1. Install Arch and boot into the new system (base + kernel + firmware).
2. Create a normal user and configure sudo (e.g., add to `wheel` and enable sudo in `/etc/sudoers`).
3. Enable networking and reboot into your new system:

```bash
sudo systemctl enable --now NetworkManager
```

4. Log in as your normal user and clone this repo:

```bash
git clone https://github.com/Niller2005/archbtw.git
cd archbtw
```

5. Run the setup script:

```bash
chmod +x setup.sh
./setup.sh
```

If you already have a base Arch install with sudo and networking working, you can jump directly to the Usage section.

## Usage

From this repository:

```bash
chmod +x setup.sh
./setup.sh
```

You will be prompted whether to configure autologin + auto-start on `tty1`.

## Dotfiles (GNU Stow)

Dotfiles live under `dotfiles/` and are linked into `~` with GNU Stow during setup:

- `dotfiles/niri` → `~/.config/niri`
- `dotfiles/noctalia` → `~/.config/noctalia`
- `dotfiles/nvim` → `~/.config/nvim`
- `dotfiles/oh-my-posh` → `~/.config/oh-my-posh`
- `dotfiles/zsh` → `~/.zshrc`

## What gets modified

- `~/.config/nvim` (AstroNvim template + theme integration)
- `~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/nvim` (backed up if present)
- `~/.config/noctalia/user-templates.toml`
- `~/.config/niri/config.kdl`
- `~/.config/oh-my-posh/powerlevel10k_lean.omp.json`
- `~/.zshrc`
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
- Zsh config includes Zinit, FZF, Zoxide, and Oh My Posh initialization.

## References

- Noctalia Neovim guide: https://docs.noctalia.dev/theming/program-specific/neovim/
- AstroNvim docs: https://docs.astronvim.com/