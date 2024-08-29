{
  description = "Collection of Nix packages for EPIC experiment at EIC";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  inputs.site-overlay.url = "github:veprbl/empty-overlay-flake";

  # define source repositories as flake inputs to enable overrides from CLI
  inputs.acts-src = {
    url = "github:acts-project/acts/v31.2.0";
    flake = false;
  };
  inputs.algorithms-src = {
    url = "github:eic/algorithms/6a0e78e3463004bacd78fcb234019f6db5257a9a";
    flake = false;
  };
  inputs.dd4hep-src = {
    url = "github:AIDASoft/DD4hep/v01-29";
    flake = false;
  };
  inputs.edm4eic-src = {
    url = "github:eic/EDM4eic/v7.0.0";
    flake = false;
  };
  inputs.edm4hep-src = {
    url = "github:key4hep/EDM4hep/v00-10-05";
    flake = false;
  };
  inputs.epic-src = {
    url = "github:eic/epic/24.07.0";
    flake = false;
  };
  inputs.eicrecon-src = {
    url = "github:eic/EICrecon/v1.16.1";
    flake = false;
  };
  inputs.geant4-src = {
    url = "https://cern.ch/geant4-data/releases/geant4-v11.1.3.tar.gz";
    flake = false;
  };
  inputs.jana2-src = {
    url = "github:JeffersonLab/JANA2/v2.3.0";
    flake = false;
  };
  inputs.juggler-src = {
    url = "gitlab:EIC/juggler/v14.2.0?host=eicweb.phy.anl.gov";
    flake = false;
  };
  inputs.podio-src = {
    url = "github:AIDASoft/podio/v01-00-01";
    flake = false;
  };

  outputs = { self, nixpkgs, site-overlay, ... }@inputs:
    let

      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        # Will assume that the flake user agrees to use non-free EIC software
        config.allowUnfreePredicate = pkg:
          (builtins.elem pkg.pname [ "afterburner" "athena" "BeastMagneticField" "eic-smear" "epic" "hepmcmerger" "npdet" "npsim" "pythia6" ])
          || lib.hasPrefix "ecce-detectors" pkg.pname
          || lib.hasPrefix "fun4all_coresoftware" pkg.pname
          || lib.hasPrefix "fun4all_eicdetectors" pkg.pname
          ;
      };

    in
    {

      overlays.default = lib.composeManyExtensions [
        (import ./overlay.nix inputs)
        site-overlay.overlays.default
      ];

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
          includePredicate = attr: pkg:
             !(builtins.elem attr [ "athena" "BeastMagneticField" "fun4all" "genfit" "pythia6" "rave" "veccore" "vecgeom" ]);
        in
          {
            default = pkgs.mkShell rec {
              buildInputs =
                builtins.attrValues (lib.filterAttrs includePredicate self.packages.${system}) ++
                (with self.packages.${system}; [
                  geant4.data.G4EMLOW
                  geant4.data.G4ENSDFSTATE
                  geant4.data.G4ENSDFSTATE
                  geant4.data.G4PARTICLEXS
                  geant4.data.G4PhotonEvaporation
                ]);
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
