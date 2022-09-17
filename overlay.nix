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

  edm4eic = callPackage pkgs/edm4eic {};

  edm4hep = callPackage pkgs/edm4hep {};

  eicrecon = callPackage pkgs/eicrecon {};

  eic-smear = callPackage pkgs/eic-smear {};

  ftgl = prev.ftgl.overrideAttrs (_: lib.optionalAttrs stdenv.isDarwin {
    # Fix build on GitHub Actions
    # https://github.com/NixOS/nixpkgs/pull/191577
    postPatch = ''
      substituteInPlace m4/gl.m4 \
        --replace ' -dylib_file $GL_DYLIB: $GL_DYLIB' ""
    '';
  });

  fun4all = callPackage pkgs/fun4all {};

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

  root = prev.root.overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=17"
      "-Dssl=ON" # for Gaudi
      "-Dbuiltin_unuran=ON"
      "-Dpythia6=ON" # for fun4all
      "-Dunuran=ON" # for sartre
    ];
    buildInputs  = prev.buildInputs ++ [
      openssl
      pythia6
    ];
  });

  dd4hep = callPackage pkgs/dd4hep {
    inherit (darwin.apple_sdk.frameworks) AGL OpenGL;
  };

  podio = callPackage pkgs/podio {};

  pythia6 = callPackage pkgs/pythia6 {};

  rave = callPackage pkgs/rave {};

  sartre = callPackage pkgs/sartre {};

}
