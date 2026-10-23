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
          ./modules/certificates.nix
          ./modules/nginx/nginx.nix
          ./modules/knot/knot.nix
          ./modules/tor.nix
          ./modules/znc.nix
          ./modules/goaccess.nix
        ];
      };

      # nix run .#deploy-odin       (switch)
      # nix run .#deploy-odin-boot  (activate on next reboot)
      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mkDeploy = name: action: {
            type = "app";
            program = "${pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = [ pkgs.nixos-rebuild ];
              text = ''
                nixos-rebuild ${action} \
                  --flake .#odin \
                  --target-host ${deployUser}@${hosts.odin} \
                  --build-host ${deployUser}@${hosts.odin} \
                  --sudo \
                  "$@"
              '';
            }}/bin/${name}";
          };
        in {
          deploy-odin = mkDeploy "deploy-odin" "switch";
          deploy-odin-boot = mkDeploy "deploy-odin-boot" "boot";
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
