final: prev: with final; {

  edm4hep = callPackage pkgs/edm4hep/default.nix {};

  root = prev.root.overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=17"
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
