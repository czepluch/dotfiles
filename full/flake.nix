{
  description = "NixOS configuration with Home Manager for development workflow";

  inputs = {
    # Core nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management (optional)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware quirks
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, hyprland, ... }@inputs:
    let
      system = "x86_64-linux";

      # Helper to create pkgs with overlays
      pkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
        overlays = [
          # Custom overlays
          self.overlays.default
          # Hyprland overlay
          hyprland.overlays.default
        ];
      };

      # Stable packages for fallback
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs = pkgsFor system;

      # Common arguments passed to all configurations
      commonArgs = {
        inherit inputs;
        inherit pkgs pkgs-stable;
      };

    in {
      # Custom overlays
      overlays.default = final: prev: {
        # Custom packages
        inherit (self.packages.${system}) cursor-appimage warp-terminal;
      };

      # Custom packages
      packages.${system} = {
        cursor-appimage = pkgs.callPackage ./nix/packages/cursor.nix {};
        warp-terminal = pkgs.callPackage ./nix/packages/warp.nix {};
      };

      # NixOS configurations
      nixosConfigurations = {
        # Main development machine
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = commonArgs;
          modules = [
            ./nix/hosts/laptop/system.nix
            # Global modules
            ./nix/modules/system/nix.nix
            ./nix/modules/system/security.nix
            ./nix/modules/desktop/hyprland.nix
            # Hardware support
            inputs.nixos-hardware.nixosModules.common-gpu-amd
            inputs.nixos-hardware.nixosModules.common-cpu-amd
          ];
        };
      };

      # Home Manager configurations
      homeConfigurations = {
        "dev@laptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = commonArgs;
          modules = [
            ./nix/home/dev/home.nix
            # Desktop modules
            ./nix/modules/home/desktop
            ./nix/modules/home/development
            ./nix/modules/home/shell
            # Hyprland home module
            hyprland.homeManagerModules.default
          ];
        };
      };

      # Development shell for working on this config
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixd               # Nix LSP
          nil                # Another Nix LSP
          nixpkgs-fmt       # Nix formatter
          statix            # Nix linter
          deadnix           # Dead code elimination

          # Home Manager
          home-manager

          # Git and tools
          git
          just              # Command runner

          # Documentation
          mdbook
        ];

        shellHook = ''
          echo "🚀 NixOS dotfiles development environment"
          echo "Available commands:"
          echo "  nixos-rebuild switch --flake .#laptop"
          echo "  home-manager switch --flake .#dev@laptop"
          echo "  nix flake update"
          echo "  nix flake check"
        '';
      };

      # Formatting for nix fmt
      formatter.${system} = pkgs.nixpkgs-fmt;

      # Templates for new configurations
      templates = {
        host = {
          path = ./templates/host;
          description = "Template for a new NixOS host configuration";
        };

        home = {
          path = ./templates/home;
          description = "Template for a new Home Manager user configuration";
        };
      };
    };
}
