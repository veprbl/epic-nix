final: prev: with final; {

  acts = callPackage pkgs/acts {};

  acts-dd4hep = callPackage pkgs/acts-dd4hep {};

  edm4hep = callPackage pkgs/edm4hep/default.nix {};

  eicd = callPackage pkgs/eicd/default.nix {};

  gaudi = callPackage pkgs/gaudi/default.nix {
    inherit (darwin.apple_sdk.frameworks) Foundation;
  };

  root = prev.root.overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=17"
      "-Dssl=ON" # for Gaudi
    ];
    buildInputs  = prev.buildInputs ++ [
      openssl
    ];
  });

  dd4hep = callPackage pkgs/dd4hep/default.nix {
    geant4 = geant4.overrideAttrs (prev: {
      cmakeFlags = prev.cmakeFlags ++ [
        "-DGEANT4_BUILD_TLS_MODEL=global-dynamic"
      ];
    });
  };

  podio = callPackage pkgs/podio/default.nix {};

}
