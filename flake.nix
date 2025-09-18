{
  description = "Portable Home Manager configuration for macOS and NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    # System-specific settings
    macosSystem = "aarch64-darwin";  # For Apple Silicon. Use "x86_64-darwin" for Intel
    nixosSystem = "x86_64-linux";    # Adjust if using ARM Linux

    # User settings (adjust these)
    username = "jacob";
    macosHome = "/Users/${username}";
    nixosHome = "/home/${username}";
    gitName = "Jacob Czepluch";
    gitEmail = "j.czepluch@proton.me";  # From your minimal config
  in
  {
    # macOS configuration
    homeConfigurations."${username}@macos" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${macosSystem};

      modules = [
        ./home/common.nix
        ./home/macos.nix
        {
          home = {
            username = username;
            homeDirectory = macosHome;
            stateVersion = "24.05";
          };

          # Pass through user settings
          _module.args = {
            inherit gitName gitEmail;
          };
        }
      ];
    };

    # NixOS configuration (for future use)
    homeConfigurations."${username}@nixos" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${nixosSystem};

      modules = [
        ./home/common.nix
        ./home/nixos.nix
        {
          home = {
            username = username;
            homeDirectory = nixosHome;
            stateVersion = "24.05";
          };

          # Pass through user settings
          _module.args = {
            inherit gitName gitEmail;
          };
        }
      ];
    };
  };
}
