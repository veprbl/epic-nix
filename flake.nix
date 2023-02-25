{
  description = "Collection of Nix packages for EPIC experiment at EIC";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, ... }:
    let

      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        # Will assume that the flake user agrees to use non-free EIC software
        config.allowUnfreePredicate = pkg:
          (builtins.elem pkg.pname [ "afterburner" "athena" "BeastMagneticField" "EICrecon" "eic-smear" "epic" "ip6" "irt" "npdet" "npsim" "pythia6" ])
          || lib.hasPrefix "ecce-detectors" pkg.pname
          || lib.hasPrefix "fun4all_coresoftware" pkg.pname
          || lib.hasPrefix "fun4all_eicdetectors" pkg.pname
          ;
      };

    in
    {

      overlays.default = import ./overlay.nix;

      packages = lib.genAttrs supportedSystems
        (system:
          let
            pkgs = pkgsFor system;
            providedPackageList = builtins.attrNames (self.overlays.default {} {});

            is_broken = pkg: (pkg.meta or {}).broken or false;
            select_unbroken = lib.filterAttrs (name: pkg: !(is_broken pkg));
          in
            lib.filterAttrs (name: lib.isDerivation)
            (select_unbroken (lib.getAttrs providedPackageList pkgs)));

      checks = self.packages;

      # Default "development" shell provides all available packages (accessed via "nix develop")
      devShells = lib.genAttrs supportedSystems (system:
        let
          pkgs = pkgsFor system;
        in
          {
            default = pkgs.mkShell rec {
              buildInputs = builtins.attrValues self.packages.${system};
            };

            eicrecon-env = pkgs.mkShell rec {
              buildInputs = with self.packages.${system}; [
                dd4hep
                edm4eic
                edm4hep
                eicrecon
                epic
                irt
                jana2
                podio
                root
              ];
              shellHook = let
                var_name = "${lib.optionalString pkgs.stdenv.isDarwin "DY"}LD_LIBRARY_PATH";
              in with self.packages.${system}; ''
                export ${var_name}=${"$"}${var_name}:${lib.makeLibraryPath [ podio irt edm4hep edm4eic ]}
              '';
            };

            fun4all-env = pkgs.mkShell rec {
              buildInputs = with self.packages.${system}; [
                fun4all
                root
                sartre
                geant4.data.G4EMLOW
                geant4.data.G4ENSDFSTATE
                geant4.data.G4ENSDFSTATE
                geant4.data.G4PARTICLEXS
                geant4.data.G4PhotonEvaporation
              ];
            };
          });

    };
}
