{
  description = "macOS Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";  # Use nixos-unstable (latest) for macOS

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    # macOS system (change to "x86_64-darwin" for Intel Macs)
    system = "aarch64-darwin";

    # User settings (customize these)
    username = "jacob";
    gitName = "Jacob Czepluch";
    gitEmail = "j.czepluch@proton.me";
  in
  {
    # macOS Home Manager configuration
    homeConfigurations."${username}@macos" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = true;  # Allow packages like Ghostty that claim Linux-only but work on macOS
        };
      };

      modules = [
        ./home/common.nix
        ./home/macos.nix
        {
          home = {
            username = username;
            homeDirectory = "/Users/${username}";
            stateVersion = "24.05";
          };

          # Pass through user settings
          _module.args = {
            inherit gitName gitEmail;
          };
        }
      ];
    };

    # Development shell for managing this config
    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      buildInputs = with nixpkgs.legacyPackages.${system}; [
        git
        nixpkgs-fmt
      ];

      shellHook = ''
        echo "🍎 macOS Home Manager Configuration"
        echo ""
        echo "📖 Commands:"
        echo "  home-manager switch --flake .#${username}@macos"
        echo "  nix flake update"
        echo "  nix flake check"
        echo ""
        echo "📝 Edit user settings in flake.nix"
      '';
    };

    # Formatter
    formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
  };
}