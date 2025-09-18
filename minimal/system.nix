# Minimal NixOS System Configuration
# This handles system-level settings that need root access
{ config, pkgs, hyprland, ... }:

{
  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Latest kernel for better hardware support
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Network
  networking = {
    hostName = "anonfunc";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Time and locale
  time.timeZone = "Europe/Copenhagen";
  i18n.defaultLocale = "en_US.UTF-8";

  # Keyboard layouts (system-wide)
  services.xserver.xkb = {
    layout = "us,dk";
    options = "grp:ctrl_space_toggle";  # Ctrl+Space to switch layouts
  };

  # Audio with PipeWire
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Graphics (AMD optimized)
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Hyprland (install system-wide)
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.system}.hyprland;
  };

  # Login manager
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
  };

  # Enable polkit for authentication
  security.polkit.enable = true;

  # User account
  users.users.jstcz = {
    isNormalUser = true;
    description = "Main User";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    shell = pkgs.zsh;
  };

  # System packages (minimal - most apps go in home.nix)
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
  ];

  # Enable Zsh system-wide
  programs.zsh.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    noto-fonts
    noto-fonts-emoji
  ];

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Don't change this after installation
  system.stateVersion = "24.05";
}
