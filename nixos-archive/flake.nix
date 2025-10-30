{
  description = "NixOS Starter - A great first-time NixOS configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop Environment
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Firefox extensions
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin theme
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    hyprland,
    nixos-hardware,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Helper to create pkgs with overlays
    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
        overlays = [
          # Hyprland overlay for latest packages
          hyprland.overlays.default
        ];
      };

    pkgs = pkgsFor system;
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };

    # User configuration - customize these
    userConfig = {
      username = "jstcz";
      name = "Jacob Czepluch";
      email = "j.czepluch@proton.me";
      hostname = "anonfunc";
      timezone = "Europe/Copenhagen";
      locale = "en_US.UTF-8";
      keyboardLayouts = "us,dk";
      keyboardSwitchKey = "grp:ctrl_space_toggle";
    };

    # Common arguments passed to all modules
    commonArgs = {
      inherit inputs userConfig;
    };
  in {
    # NixOS system configurations
    nixosConfigurations = {
      # Main configuration - rename this to your hostname
      ${userConfig.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = commonArgs;
        modules = [
          ({config, ...}: {
            nixpkgs.pkgs = pkgsFor system;
            _module.args.pkgs-stable = pkgs-stable;
          })
          # Hardware (generated during installation)
          ./hardware-configuration.nix

          # Core system configuration
          ./system/core.nix

          # Desktop environment
          ./system/desktop.nix

          # Optional modules (comment out what you don't need)
          # ./system/optional/development.nix  # Commented for minimal setup
          # ./system/optional/gaming.nix
          # ./system/optional/multimedia.nix

          # Hardware optimizations (AMD laptop with SSD)
          nixos-hardware.nixosModules.common-gpu-amd
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd

          # Override to keep amdgpu driver (not modesetting from nixos-hardware)
          ({lib, ...}: {
            services.xserver.videoDrivers = lib.mkForce ["amdgpu"];
          })
        ];
      };
    };

    # Home Manager configurations
    homeConfigurations = {
      "${userConfig.username}@${userConfig.hostname}" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor system;
        extraSpecialArgs = commonArgs;
        modules = [
          # Base user configuration
          ./home/default.nix

          # Desktop applications and settings
          ./home/desktop.nix

          # Choose your profile (comment out others)
          # ./home/profiles/developer.nix  # Heavy dev tools
          # ./home/profiles/creative.nix

          # Hyprland Home Manager module
          hyprland.homeManagerModules.default

          # Catppuccin theme module
          inputs.catppuccin.homeModules.catppuccin
        ];
      };
    };

    # Development shell for managing this configuration
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        # Nix development tools
        nixd # Nix LSP
        nil # Alternative Nix LSP
        nixpkgs-fmt # Nix formatter
        statix # Nix linter
        deadnix # Find dead Nix code

        # System management
        home-manager
        git

        # Command runner (better than make)
        just

        # Documentation
        mdbook
      ];

      shellHook = ''
        echo "🚀 NixOS Starter Development Environment"
        echo ""
        echo "📖 Getting started:"
        echo "  just install          # Initial system setup"
        echo "  just rebuild          # Rebuild system"
        echo "  just home-rebuild     # Rebuild user config"
        echo "  just update           # Update flake inputs"
        echo "  just clean            # Clean old generations"
        echo ""
        echo "🔧 Development:"
        echo "  just check            # Check configuration"
        echo "  just fmt              # Format Nix files"
        echo "  just lint             # Lint Nix files"
        echo ""
        echo "📝 Edit userConfig in flake.nix to customize your setup"
      '';
    };

    # Nix formatter
    formatter.${system} = pkgs.nixpkgs-fmt;

    # Templates for creating new configurations
    templates = {
      default = {
        path = ./.;
        description = "NixOS Starter - A great first-time NixOS configuration";
      };
    };

    # Packages we might want to expose
    packages.${system} = {
      # Custom packages can go here
    };
  };
}
