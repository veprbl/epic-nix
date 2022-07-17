final: prev: with final; {

  acts = callPackage pkgs/acts {};

  acts-dd4hep = callPackage pkgs/acts-dd4hep {};

  edm4hep = callPackage pkgs/edm4hep {};

  eicd = callPackage pkgs/eicd {};

  gaudi = callPackage pkgs/gaudi {
    inherit (darwin.apple_sdk.frameworks) Foundation;
  };

  genfit = callPackage pkgs/genfit {};

  ip6 = callPackage pkgs/ip6 {};

  jana2 = callPackage pkgs/jana2 {};

  juggler = callPackage pkgs/juggler {};

  root = prev.root.overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=17"
      "-Dssl=ON" # for Gaudi
    ];
    buildInputs  = prev.buildInputs ++ [
      openssl
    ];
  });

  dd4hep = callPackage pkgs/dd4hep {
    geant4 = geant4.overrideAttrs (prev: {
      cmakeFlags = prev.cmakeFlags ++ [
        "-DGEANT4_BUILD_TLS_MODEL=global-dynamic"
      ];
    });
  };

  podio = callPackage pkgs/podio {};

}
