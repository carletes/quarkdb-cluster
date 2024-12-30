{
  description = "A toy QuarkDB cluster (https://eos-web.web.cern.ch/eos-web/)";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-anywhere.url = "github:nix-community/nixos-anywhere";
  inputs.nixos-anywhere.inputs.disko.follows = "disko";
  inputs.nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.quarkdb-nix.url = "git+https://codeberg.org/carletes/quarkdb-nix?ref=main";
  inputs.quarkdb-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.quarkdb-nix.inputs.flake-utils.follows = "flake-utils";

  outputs = { nixpkgs, disko, flake-utils, nixos-anywhere, quarkdb-nix, ... }:
    let
      overlays = [ quarkdb-nix.overlays.default ];
      quarkdbConfig = hostname: {
        system = "x86_64-linux";
        modules = [
          { nixpkgs.overlays = overlays; }
          disko.nixosModules.disko
          ./nixos/configuration.nix

          { networking.hostName = hostname; }
        ];
      };
    in
    {
      nixosConfigurations = {
        quarkdb-0 = nixpkgs.lib.nixosSystem (quarkdbConfig "quarkdb-0");
        quarkdb-1 = nixpkgs.lib.nixosSystem (quarkdbConfig "quarkdb-1");
        quarkdb-2 = nixpkgs.lib.nixosSystem (quarkdbConfig "quarkdb-2");
      };
    } // (
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              cdrtools
              jq
              (opentofu.withPlugins (p: [ p.null p.external p.libvirt ]))
              nixos-anywhere.packages.${system}.nixos-anywhere
            ];

            shellHook = ''
              export LIBVIRT_DEFAULT_URI="qemu:///system"
            '';
          };
        })
    );
}
