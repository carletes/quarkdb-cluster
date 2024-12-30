{
  description = "A toy QuarkDB cluster (https://eos-web.web.cern.ch/eos-web/)";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.disko.inputs.flake-parts.follows = "flake-parts";

  inputs.nixos-anywhere.url = "github:nix-community/nixos-anywhere";
  inputs.nixos-anywhere.inputs.disko.follows = "disko";
  inputs.nixos-anywhere.inputs.flake-parts.follows = "flake-parts";
  inputs.nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

  inputs.quarkdb-nix.url = "git+https://codeberg.org/carletes/quarkdb-nix?ref=main";
  inputs.quarkdb-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, disko, flake-parts, nixos-anywhere, quarkdb-nix, ... }@inputs:
    let
      overlays = [ quarkdb-nix.overlays.default ];
      nixosVars = builtins.fromJSON (builtins.readFile ./nixos/nix_vars.json);
    in

    flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        flake = {
          nixosConfigurations = lib.mapAttrs
            (
              hostname: _: nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                  { nixpkgs.overlays = overlays; }
                  disko.nixosModules.disko
                  ./nixos/configuration.nix

                  {
                    networking.hostName = hostname;
                    networking.hosts = lib.mapAttrs' (hostname: v: lib.nameValuePair (v.ipv4_address) [ hostname ]) nixosVars;
                  }
                ];
              }
            )
            nixosVars;
        };

        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-darwin"
          "x86_64-linux"
        ];

        perSystem = { pkgs, ... }: {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              cdrtools
              jq
              (opentofu.withPlugins (p: [ p.local p.libvirt ]))
              nixos-anywhere.packages.${system}.nixos-anywhere
            ];

            shellHook = ''
              export LIBVIRT_DEFAULT_URI="qemu:///system"
            '';
          };

        };
      }
    );
}
