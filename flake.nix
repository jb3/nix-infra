{
  description = "Personal NixOS infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, agenix, ... }:
    let
      devSystem = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${devSystem};

      deployUser = "joe";
      hosts = {
        odin = "odin.host.jb3.dev";
      };

      deployOdin = pkgs.writeShellApplication {
        name = "deploy-odin";
        runtimeInputs = [ pkgs.nixos-rebuild ];
        text = ''
          nixos-rebuild switch \
            --flake .#odin \
            --target-host ${deployUser}@${hosts.odin} \
            --build-host ${deployUser}@${hosts.odin} \
            --sudo \
            "$@"
        '';
      };
    in
    {
      nixosConfigurations.odin = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          ./hosts/odin
          ./modules/common.nix
          ./modules/users.nix
          ./modules/ssh.nix
        ];
      };

      # nix run .#deploy-odin
      apps.${devSystem}.deploy-odin = {
        type = "app";
        program = "${deployOdin}/bin/deploy-odin";
      };

      # nix develop
      devShells.${devSystem}.default = pkgs.mkShell {
        name = "nix-infra";
        packages = [
          pkgs.nixos-rebuild
          agenix.packages.${devSystem}.default
          pkgs.ssh-to-age
        ];
      };
    };
}
