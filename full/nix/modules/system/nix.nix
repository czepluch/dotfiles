# Nix configuration module
{ config, lib, pkgs, inputs, ... }:

{
  # Enable flakes and new nix command
  nix = {
    settings = {
      # Enable flakes and new command
      experimental-features = [ "nix-command" "flakes" ];

      # Optimize storage
      auto-optimise-store = true;

      # Substituters for faster builds
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];

      # Allow users in wheel group to use nix
      trusted-users = [ "root" "@wheel" ];

      # Warn about dirty git repos
      warn-dirty = false;

      # Keep build logs
      log-lines = 50;

      # Build timeout
      timeout = 3600; # 1 hour

      # Keep failed builds for debugging
      keep-failed = true;

      # Keep outputs of derivations
      keep-outputs = true;
      keep-derivations = true;
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Registry for flake inputs
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Pin nixpkgs to the same version as our flake
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    # Optimize nix store
    optimise = {
      automatic = true;
      dates = [ "03:45" ]; # Run at 3:45 AM
    };

    # Build settings
    buildMachines = [ ];
    distributedBuilds = false;

    # Maximum number of parallel jobs
    settings.max-jobs = "auto";
    settings.cores = 0; # Use all available cores
  };

  # Allow unfree packages globally
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;

    # Allow insecure packages if needed (use sparingly)
    # permittedInsecurePackages = [ ];

    # Package-specific settings
    packageOverrides = pkgs: {
      # Example: override a package
      # somePackage = pkgs.somePackage.override { enableFeature = true; };
    };
  };

  # Documentation
  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    info.enable = true;
    doc.enable = true;
  };

  # System packages needed for nix functionality
  environment.systemPackages = with pkgs; [
    git        # Required for flakes
    cachix     # Binary cache management
    nix-index  # Locate packages providing a file
    nix-tree   # Visualize nix store
    nixfmt     # Nix formatter
  ];

  # Nix-related services
  services = {
    # Nix daemon
    nix-daemon.enable = true;

    # Locate service for nix-index
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "daily";
    };
  };

  # Environment variables
  environment.variables = {
    # Point to the location of this flake
    FLAKE = "/home/dev/dotfiles";

    # Nix-specific variables
    NIX_PATH = lib.mkForce "nixpkgs=${inputs.nixpkgs}";
  };

  # Shell aliases for common nix operations
  environment.shellAliases = {
    # System rebuilds
    rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles";
    rebuild-test = "sudo nixos-rebuild test --flake ~/dotfiles";
    rebuild-boot = "sudo nixos-rebuild boot --flake ~/dotfiles";

    # Flake operations
    flake-update = "cd ~/dotfiles && nix flake update";
    flake-check = "cd ~/dotfiles && nix flake check";

    # Garbage collection
    nix-gc = "sudo nix-collect-garbage -d";
    nix-gc-old = "sudo nix-collect-garbage --delete-older-than 7d";

    # Store operations
    nix-optimise = "sudo nix-store --optimise";
    nix-store-size = "du -sh /nix/store";

    # Search packages
    search = "nix search nixpkgs";

    # Development
    nix-shell-p = "nix-shell -p";
    nix-run = "nix run nixpkgs#";
  };

  # Systemd services for maintenance
  systemd.timers."nix-gc" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1h";
      OnUnitActiveSec = "1w";
      Unit = "nix-gc.service";
    };
  };

  systemd.services."nix-gc" = {
    script = ''
      ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 30d
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
