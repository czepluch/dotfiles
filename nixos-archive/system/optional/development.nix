# Development Tools and Services
# Optional module for development environment
{ config, pkgs, ... }:

{
  # Development services
  services = {
    # Note: Docker is enabled via virtualisation.docker, not services.docker

    # PostgreSQL (uncomment if needed)
    # postgresql = {
    #   enable = true;
    #   package = pkgs.postgresql_15;
    #   authentication = pkgs.lib.mkOverride 10 ''
    #     local all all trust
    #     host all all 127.0.0.1/32 trust
    #     host all all ::1/128 trust
    #   '';
    # };

    # Redis (uncomment if needed)
    # redis = {
    #   servers.main = {
    #     enable = true;
    #     port = 6379;
    #   };
    # };
  };

  # Add docker group to user (automatically created by virtualisation.docker)
  # users.groups.docker = { };  # Not needed, created automatically

  # Development tools (system-wide)
  environment.systemPackages = with pkgs; [
    # Version control
    git-lfs

    # Build tools
    gcc
    gnumake
    cmake
    pkg-config

    # Language runtimes (add what you need)
    nodejs_20
    python3
    rustc
    cargo
    go

    # Database tools
    sqlite
    # postgresql  # Uncomment if using postgres service

    # Container tools
    docker-compose  # If using docker

    # Network tools for development
    netcat
    nmap
    wireshark-cli
  ];

  # Virtualization (for VMs, containers)
  virtualisation = {
    # Docker
    docker.enable = true;

    # VirtualBox (uncomment if needed)
    # virtualbox.host.enable = true;

    # Libvirt (uncomment if needed for QEMU/KVM)
    # libvirtd.enable = true;
  };

  # Environment variables for development
  environment.variables = {
    # Rust
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

    # Go
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
  };
}