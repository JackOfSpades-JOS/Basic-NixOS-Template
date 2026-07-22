{
  description = "NixOS + Hyprland rice (Catppuccin Mocha, Waybar, Rofi, home-manager)";

  inputs = {
    # Tracking unstable so Hyprland/Waybar/etc. stay reasonably fresh.
    # Swap to "github:NixOS/nixpkgs/nixos-26.05" if you want a more
    # conservative, less-frequently-changing base.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # One flake input themes GTK/Qt/Kitty/Waybar/Rofi/Dunst/Hyprlock/
    # Starship/fastfetch consistently in Catppuccin Mocha.
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, ... }:
    let
      system = "x86_64-linux";

      # ---- EDIT THESE TWO LINES FIRST ----
      username = "changeme"; # your Linux username, e.g. "alex"
      hostname = "nixos";    # whatever you want this machine called
      # -------------------------------------
    in
    {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit username hostname; };
        modules = [
          ./configuration.nix
          # Generated on your own machine, NOT included here - see README.
          ./hardware-configuration.nix

          catppuccin.nixosModules.catppuccin

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.${username} = import ./home.nix;
            home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
          }
        ];
      };
    };
}
