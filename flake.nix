{
  description = "Collection of Nix packages for EPIC experiment at EIC";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  inputs.site-overlay.url = "github:veprbl/empty-overlay-flake";

  # define source repositories as flake inputs to enable overrides from CLI
  inputs.acts-src = {
    url = "github:acts-project/acts/v39.2.1";
    flake = false;
  };
  inputs.algorithms-src = {
    url = "github:eic/algorithms/v1.0.0";
    flake = false;
  };
  inputs.dd4hep-src = {
    url = "github:AIDASoft/DD4hep/v01-32";
    flake = false;
  };
  inputs.edm4eic-src = {
    url = "github:eic/EDM4eic/v8.0.0";
    flake = false;
  };
  inputs.edm4hep-src = {
    url = "github:key4hep/EDM4hep/v00-99-01";
    flake = false;
  };
  inputs.epic-src = {
    url = "github:eic/epic/25.08.0";
    flake = false;
  };
  inputs.eicrecon-src = {
    url = "github:eic/EICrecon/v1.28.0";
    flake = false;
  };
  inputs.geant4-src = {
    url = "https://cern.ch/geant4-data/releases/geant4-v11.3.2.tar.gz";
    flake = false;
  };
  inputs.hepmcmerger-src = {
    url = "github:eic/HEPMC_Merger/v2.0.0";
    flake = false;
  };
  inputs.jana2-src = {
    url = "github:JeffersonLab/JANA2/v2.4.2";
    flake = false;
  };
  inputs.juggler-src = {
    url = "gitlab:EIC/juggler/v15.0.2?host=eicweb.phy.anl.gov";
    flake = false;
  };
  inputs.podio-src = {
    url = "github:AIDASoft/podio/v01-01";
    flake = false;
  };

  outputs = { self, nixpkgs, site-overlay, ... }@inputs:
    let

      inherit (nixpkgs) lib;
      supportedSystems = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];

      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        # Will assume that the flake user agrees to use non-free EIC software
        config.allowUnfreePredicate = pkg:
          (builtins.elem pkg.pname [ "afterburner" "BeastMagneticField" "eic-smear" "epic" "hepmcmerger" "npdet" "npsim" "osg-ca-certs" "pythia6" ])
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
             !(builtins.elem attr [ "BeastMagneticField" "fun4all" "genfit" "pythia6" "rave" "veccore" "vecgeom" ]);
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

          } // lib.optionalAttrs (system == "x86_64-linux") {
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
