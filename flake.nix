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
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      devSystem = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${devSystem};

      deployUser = "joe";
      hosts = {
        odin = "odin.host.jb3.dev";
      };
    in
    {
      nixosConfigurations.odin = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self; };
        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          ./hosts/odin
          ./modules/common.nix
          ./modules/users.nix
          ./modules/ssh.nix
          ./modules/knot/knot.nix
        ];
      };

      # nix run .#deploy-odin
      apps = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          deploy-odin = {
            type = "app";
            program = "${pkgs.writeShellApplication {
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
            }}/bin/deploy-odin";
          };
        });

      # nix develop
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            name = "nix-infra";
            packages = [
              pkgs.nixos-rebuild
              agenix.packages.${system}.default
              pkgs.ssh-to-age
            ];
          };
        });
    };
}
