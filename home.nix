{ config, pkgs, ... }:

{
  home.username = "changeme";           # must match the `username` in flake.nix
  home.homeDirectory = "/home/changeme"; # must match the `username` in flake.nix
  home.stateVersion = "26.05";       # keep in sync with configuration.nix

  programs.home-manager.enable = true;

  ############################################
  # Theme - one switch, themes GTK/Qt/Kitty/
  # Waybar/Rofi/Dunst/Hyprlock/Starship/fastfetch
  ############################################
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };

  gtk.enable = true;
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";       # Electron apps (Discord/VSCode/Cursor) go native Wayland
    MOZ_ENABLE_WAYLAND = "1";   # Firefox native Wayland
    QT_QPA_PLATFORM = "wayland;xcb";
  };
  home.sessionPath = [ "$HOME/.local/bin" ];

  ############################################
  # Applications
  ############################################
  home.packages = with pkgs; [
    # Browsers / chat
    brave
    discord

    # Media
    vlc
    mpv
    obs-studio

    # Office
    libreoffice

    # Code editors
    vscode
    neovim
    code-cursor # AI editor - needs allowUnfree, set in configuration.nix

    # Gaming
    prismlauncher # Minecraft launcher

    # File manager
    kdePackages.dolphin

    # Wayland rice utilities
    swww          # animated wallpaper daemon
    grim
    slurp
    swappy        # screenshot annotation
    wf-recorder   # screen recording (bind it, or pair with OBS)
    cliphist
    wl-clipboard
    playerctl
    brightnessctl
    pavucontrol
    networkmanagerapplet
  ];

  programs.firefox.enable = true;

  ############################################
  # Terminal
  ############################################
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    settings = {
      background_opacity = "0.92";
      confirm_os_window_close = 0;
    };
  };

  ############################################
  # Shell
  ############################################
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    history.size = 10000;
    shellAliases = {
      ll = "ls -la";
      rebuild = "sudo nixos-rebuild switch --flake .#nixos";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
    };
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo.source = "nixos_small";
      display.separator = "  ";
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "display"
        "de"
        "wm"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "disk"
        "break"
        "colors"
      ];
    };
  };

  ############################################
  # Launcher
  ############################################
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "${pkgs.kitty}/bin/kitty";
  };

  ############################################
  # Notifications
  ############################################
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 100;
        offset = "30x30";
        origin = "top-right";
        transparency = 10;
        frame_width = 2;
        corner_radius = 10;
        font = "JetBrainsMono Nerd Font 10";
      };
    };
  };

  ############################################
  # Bar
  ############################################
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "bluetooth"
          "cpu"
          "memory"
          "battery"
        ];
        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
        };
        clock = {
          format = "{:%a %d %b  %H:%M}";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "muted";
          on-click = "pavucontrol";
        };
        network = {
          format-wifi = "  {essid}";
          format-ethernet = "  connected";
          format-disconnected = "  disconnected";
        };
        bluetooth = {
          format = "";
          format-connected = " {device_alias}";
        };
        battery = {
          format = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
        };
        cpu.format = " {usage}%";
        memory.format = " {used:0.1f}G";
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }
      window#waybar {
        border-radius: 10px;
        margin: 6px 10px;
      }
      #workspaces button {
        padding: 0 8px;
      }
      #clock, #pulseaudio, #network, #bluetooth, #cpu, #memory, #battery, #tray {
        padding: 0 10px;
      }
    '';
  };

  ############################################
  # Lock / idle
  ############################################
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [{
        path = "screenshot";
        blur_passes = 2;
        blur_size = 7;
      }];
      input-field = [{
        size = "250, 60";
        placeholder_text = "Password";
        fade_on_empty = false;
      }];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        { timeout = 300; on-timeout = "hyprlock"; }
        { timeout = 600; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
      ];
    };
  };

  ############################################
  # Wallpaper switcher script (SUPER+W)
  ############################################
  home.file.".local/bin/wallpaper-select" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      WALLPAPER_DIR="$HOME/Pictures/wallpapers"
      mkdir -p "$WALLPAPER_DIR"
      selected=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
        -printf "%f\n" | rofi -dmenu -p "Wallpaper")
      [ -n "$selected" ] && swww img "$WALLPAPER_DIR/$selected" \
        --transition-type wipe --transition-duration 1
    '';
  };

  ############################################
  # Hyprland
  ############################################
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "rofi -show drun";

      monitor = [ ",preferred,auto,1" ];

      exec-once = [
        "waybar"
        "dunst"
        "swww-daemon"
        "nm-applet --indicator"
        "wl-paste --watch cliphist store"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
      };

      animations = {
        enabled = true;
        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures = {
        workspace_swipe = true;
      };

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive"
        "$mod SHIFT, M, exit"
        "$mod, E, exec, $fileManager"
        "$mod, V, togglefloating"
        "$mod, D, exec, $menu"
        "$mod, F, fullscreen"
        "$mod, L, exec, hyprlock"
        "$mod, W, exec, wallpaper-select"
        "$mod SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
        ", Print, exec, grim - | swappy -f -"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindl = [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };
}
