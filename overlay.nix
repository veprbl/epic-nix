{ acts-src
, algorithms-src
, dd4hep-src
, edm4eic-src
, edm4hep-src
, epic-src
, eicrecon-src
, geant4-src
, hepmcmerger-src
, irt-src
, jana2-src
, juggler-src
, podio-src
, ...
}:

final: prev: with final; {

  acts = callPackage pkgs/acts { inherit acts-src; };

  algorithms = callPackage pkgs/algorithms { inherit algorithms-src; };

  afterburner = callPackage pkgs/afterburner {};

  aida = callPackage pkgs/aida {};

  cgal_4 = callPackage pkgs/cgal/4.nix {};

  epic = callPackage pkgs/epic { inherit epic-src; };

  edm4eic = callPackage pkgs/edm4eic { inherit edm4eic-src; };

  edm4hep = callPackage pkgs/edm4hep { inherit edm4hep-src; };

  eicrecon = callPackage pkgs/eicrecon { inherit eicrecon-src; };

  eic-smear = callPackage pkgs/eic-smear {};

  gaudi = callPackage pkgs/gaudi {};

  geant4 = (prev.geant4.override {
    enableQt = true;
  }).overrideAttrs (prev: rec {
    version = "11.3.2";
    src = geant4-src;
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=20"
      "-DGEANT4_BUILD_TLS_MODEL=global-dynamic"
    ];
  });

  hepmc3 = prev.hepmc3.overrideAttrs (old: {
      postPatch = old.postPatch or "" + ''
        substituteInPlace CMakeLists.txt \
          --replace 'SET(CMAKE_INSTALL_RPATH "''${CMAKE_INSTALL_PREFIX}/''${CMAKE_INSTALL_LIBDIR}")' \
                    'SET(CMAKE_INSTALL_RPATH "''${CMAKE_INSTALL_FULL_LIBDIR}")'
      '';
      # Prevent patchelf from stripping search paths for plugins
      # (it can't see them because they are dlopen'ed)
      dontPatchELF = true;
    });

  hepmcmerger = callPackage pkgs/hepmcmerger {
    inherit hepmcmerger-src;
  };

  irt = callPackage pkgs/irt { inherit irt-src; };

  jana2 = callPackage pkgs/jana2 { inherit jana2-src; };

  juggler = callPackage pkgs/juggler { inherit juggler-src; };

  k4FWCore = callPackage pkgs/k4FWCore {};

  npsim = callPackage pkgs/npsim {};

  #llvm_20 = null;
  llvm_20 = prev.llvm_20.overrideAttrs (prev: {
    patches = prev.patches ++ [
      (fetchpatch {
        url = "https://github.com/llvm/llvm-project/pull/169772.diff";
        stripLen = 1;
        hash = "sha256-JV/8Ued2p9z4tNbrdgN0IXb0vDYXwtNKZfZZaBU5GHk=";
      })
    ];
  });

  root = prev.root.overrideAttrs (self: {
    cmakeFlags = self.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=20"
      "-Dssl=ON" # for Gaudi
      "-Droot7=ON" "-Dwebgui=ON" "-Dbuiltin_openui5=ON" # ROOT::ROOTGeomViewer for dd4hep
    ] ++ final.lib.optionals final.stdenv.isDarwin [
      # https://github.com/AIDASoft/podio/issues/367
      "-Dimt=OFF"
    ];
    env.CXXFLAGS = lib.optionalString stdenv.isDarwin "-faligned-allocation";
    buildInputs = self.buildInputs ++ [
      openssl
    ];
  });

  dd4hep = callPackage pkgs/dd4hep {
    inherit dd4hep-src;
  };

  osg-ca-certs = callPackage pkgs/osg-ca-certs {};

  podio = callPackage pkgs/podio { inherit podio-src; };

  veccore = callPackage pkgs/veccore {};

  vecgeom = callPackage pkgs/vecgeom {};

}
