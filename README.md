# NixOS + Hyprland rice

Hyprland, Waybar, Rofi, Kitty, Dunst, PipeWire+Bluetooth, SDDM, GRUB,
Catppuccin Mocha theming (auto-applied to GTK/Qt/Kitty/Waybar/Rofi/Dunst/
Hyprlock/Starship/fastfetch via one flake), Steam+GameMode, Discord, Brave
+ Firefox, VLC, OBS, LibreOffice, VS Code + Neovim + Cursor, Prism Launcher
(Minecraft), Dolphin, screenshot/clipboard/lock tooling, and a wallpaper
picker on `SUPER+W`.

## Before you build - required edits

1. **Generate your own hardware config.** This repo does NOT include
   `hardware-configuration.nix` because it's unique to your disk/partition
   layout. From a NixOS live ISO or existing install:
   ```
   sudo nixos-generate-config --root /mnt   # or without --root if already installed
   ```
   Copy the generated `hardware-configuration.nix` into this folder.

2. **`flake.nix`** — set `username` and `hostname` to what you want.

3. **`home.nix`** — set `home.username` and `home.homeDirectory` to match.

4. **`configuration.nix`** boot section — if you're on legacy BIOS (not
   UEFI), set `efiSupport = false;` and `device = "/dev/sdX";` (your actual
   disk), and remove `boot.loader.efi.canTouchEfiVariables`.

5. Drop some images into `~/Pictures/wallpapers` after first boot, then
   `SUPER+W` to pick one (via `swww`).

## Building

```
sudo nixos-rebuild switch --flake .#nixos
```

(replace `nixos` with whatever hostname you set in `flake.nix`)

## Notes

- Timezone defaults to `UTC`, locale to `en_US.UTF-8`, keyboard to `us` —
  all generic placeholders, change them in `configuration.nix` to match you.
- `code-cursor` and Steam need `nixpkgs.config.allowUnfree = true;`, which
  is already set in `configuration.nix`.
- Battery module is in Waybar for laptop support; harmless on desktops.
- Key binds: `SUPER+Return` terminal, `SUPER+D` launcher, `SUPER+E` files,
  `SUPER+L` lock, `SUPER+W` wallpaper, `SUPER+SHIFT+S` region screenshot,
  `Print` full screenshot, `SUPER+SHIFT+V` clipboard history.

