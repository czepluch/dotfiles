# Base Profile
# Essential packages following NixOS best practices
{ config, pkgs, ... }:

{
  # Minimal set of additional packages
  home.packages = with pkgs; [
    # Basic applications
    firefox
    libreoffice

    # Media
    vlc

    # Communication (choose one)
    # discord
    # telegram-desktop

    # File management
    dolphin
    ark  # Archive manager

    # System utilities
    pavucontrol
    gnome-calculator

    # Text editor
    kate  # Simple GUI text editor
  ];

  # Simplified Zsh configuration
  programs.zsh = {
    shellAliases = {
      # Keep only essential aliases
      ll = "eza -la";
      ls = "eza";
      cat = "bat";

      # NixOS management
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
      home-rebuild = "home-manager switch --flake ~/nixos-config";

      # Basic navigation
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    initExtra = ''
      # Minimal shell configuration
      export EDITOR="kate"
      export BROWSER="firefox"

      # Simple functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
    '';
  };

  # Firefox with basic privacy settings
  programs.firefox.profiles.default.settings = {
    "privacy.trackingprotection.enabled" = true;
    "browser.startup.homepage" = "about:home";
    "browser.newtabpage.enabled" = false;
  };

  # Basic directories
  home.file = {
    "Documents/.keep".text = "";
    "Downloads/.keep".text = "";
    "Pictures/.keep".text = "";
    "Videos/.keep".text = "";
  };
}
