{ config, pkgs, username, hostname, ... }:

{
  ############################################
  # Nix / flakes
  ############################################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # needed for Steam, Discord, Cursor, etc.

  ############################################
  # Boot (GRUB, safe defaults)
  ############################################
  boot.loader.grub = {
    enable = true;
    device = "nodev";      # set to e.g. "/dev/sda" ONLY if using legacy BIOS
    efiSupport = true;      # set to false if you're on legacy BIOS, not UEFI
    useOSProber = false;    # set true if you dual-boot and want other OSes listed
  };
  boot.loader.efi.canTouchEfiVariables = true;

  ############################################
  # Networking
  ############################################
  networking.hostName = hostname;
  networking.networkmanager.enable = true; # wireless + wired, GUI-friendly
  networking.firewall.enable = true;

  ############################################
  # Locale / time - CHANGE THESE to your own
  ############################################
  time.timeZone = "UTC"; # e.g. "America/New_York", "Europe/London" - run `timedatectl list-timezones` for the full list
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us"; # e.g. "uk", "de", "fr" if your keyboard layout differs

  ############################################
  # Users
  ############################################
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "video" "input" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true; # must be enabled system-wide as a valid login shell

  ############################################
  # Audio: PipeWire + Bluetooth
  ############################################
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true; # tray applet + easy pairing UI

  ############################################
  # Graphics
  ############################################
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # needed for Steam/Proton
  };

  ############################################
  # Hyprland + display manager
  ############################################
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Required for hyprlock to actually be able to authenticate you.
  security.pam.services.hyprlock = { };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  ############################################
  # Fonts
  ############################################
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-emoji
  ];

  ############################################
  # Gaming
  ############################################
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
  };
  programs.gamemode.enable = true;

  ############################################
  # Remote access
  ############################################
  services.openssh.enable = true;

  ############################################
  # System packages that make sense outside home-manager
  ############################################
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    kdePackages.kio-extras # thumbnails/network protocols for Dolphin
  ];

  # Do not change this after your first install - it's a compatibility
  # marker, not a "keep up to date" field.
  system.stateVersion = "26.05";
}
