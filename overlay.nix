final: prev: with final; {

  acts = callPackage pkgs/acts {};

  acts-dd4hep = callPackage pkgs/acts-dd4hep {};

  aida = callPackage pkgs/aida {};

  athena = callPackage pkgs/athena {};

  ecce = epic.overrideAttrs (prev: {
    cmakeFlags = lib.warn "using outdated `ecce` attr" prev.cmakeFlags ++ [
      "-DEPIC_ECCE_LEGACY_COMPAT=ON"
    ];
  });

  epic = callPackage pkgs/epic {};

  edm4hep = callPackage pkgs/edm4hep {};

  eicd = callPackage pkgs/eicd {};

  eicrecon = callPackage pkgs/eicrecon {};

  eic-smear = callPackage pkgs/eic-smear {};

  gaudi = callPackage pkgs/gaudi {
    inherit (darwin.apple_sdk.frameworks) Foundation;
  };

  geant4 = (prev.geant4.override {
    enableQt = true;
  }).overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DGEANT4_BUILD_TLS_MODEL=global-dynamic"
    ];
  });

  genfit = callPackage pkgs/genfit {};

  ip6 = callPackage pkgs/ip6 {};

  jana2 = callPackage pkgs/jana2 {};

  juggler = callPackage pkgs/juggler {};

  root = (prev.root.override {
    # use builtin libAfterImage until https://github.com/NixOS/nixpkgs/pull/182105
    libAfterImage = null;
  }).overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=17"
      "-Dssl=ON" # for Gaudi
      "-Dbuiltin_afterimage=ON"
    ];
    buildInputs  = prev.buildInputs ++ [
      openssl
    ];
  });

  dd4hep = callPackage pkgs/dd4hep {
    inherit (darwin.apple_sdk.frameworks) AGL OpenGL;
  };

  podio = callPackage pkgs/podio {};

  rave = callPackage pkgs/rave {};

}
