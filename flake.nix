
{
  inputs = {
    nixos.url = github:nixos/nixpkgs/nixos-22.11;
    nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
  };

  outputs = {nixos, nixpkgs, ...}: {
    nixosConfigurations = with nixpkgs.lib; let
      lib = nixpkgs.lib;
      base = {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs;
        };
        modules = [
          ./configuration.nix
	  ./packet.nix
          ({imports = optional (pathExists ./local.nix) ./local.nix;})
        ];
      };
    in
      with nixpkgs.lib; {
        nixos = nixosSystem {
          inherit (base) system specialArgs;
          modules = base.modules ++ [ ./configuration.d/nixos.nix ];
        };
      };
  };
}
