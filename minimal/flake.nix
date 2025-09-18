{
  description = "Minimal NixOS configuration - perfect for getting started";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }: {
    nixosConfigurations = {
      anonfunc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit hyprland; };
        modules = [
          ./system.nix
          ./hardware-configuration.nix
        ];
      };
    };

    homeConfigurations = {
      "jstcz@anonfunc" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
