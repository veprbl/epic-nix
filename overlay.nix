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

  libAfterImage = prev.libAfterImage.overrideAttrs (prev: {
    patches = prev.patches ++ [
      # fix https://github.com/root-project/root/issues/10990
      (fetchpatch {
        url = "https://github.com/root-project/root/pull/11243/commits/e177a477b0be05ef139094be1e96a99ece06350a.diff";
        hash = "sha256-2DQmJGHmATHawl3dk9dExncVe1sXzJQyy4PPwShoLTY=";
        stripLen = 5;
      })
    ];

    # fix build on systems without XQuartz
    configureFlags = prev.configureFlags
      ++ lib.optional stdenv.isDarwin [ "--without-x" ];
  });

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

  # workaround for https://github.com/NixOS/nixpkgs/issues/185615
  qt5 = if stdenv.isDarwin then prev.qt512 else prev.qt5;
  libsForQt5 = if stdenv.isDarwin then prev.libsForQt512 else prev.libsForQt5;

  pythia6 = callPackage pkgs/pythia6 {};

  # workaround for https://github.com/NixOS/nixpkgs/pull/187356
  pythia = prev.pythia.overrideAttrs (prev: {
    nativeBuildInputs = (prev.nativeBuildInputs or [])
      ++ lib.optionals stdenv.isDarwin [ fixDarwinDylibNames ];
  });

  rave = callPackage pkgs/rave {};

  sartre = callPackage pkgs/sartre {};

}
