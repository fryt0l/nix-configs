{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # This should match the version of NixOS you want to use

    nixos-xivlauncher-rb = {
      url = "github:drakon64/nixos-xivlauncher-rb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
   {
      self,
      nixpkgs,
      nixos-xivlauncher-rb,
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            nixos-xivlauncher-rb.nixosModules.default
          ];
        };
      };
    };
}
