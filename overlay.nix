{ acts-src
, algorithms-src
, dd4hep-src
, edm4eic-src
, edm4hep-src
, epic-src
, eicrecon-src
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

  athena = callPackage pkgs/athena {};

  # geant4 requires at least version 2.4.6.0
  clhep = prev.clhep.overrideAttrs (old:
    final.lib.optionalAttrs (final.lib.versionOlder prev.clhep.version "2.4.7.1") rec {
      version = "2.4.7.1";

      src = fetchurl {
        url = "https://proj-clhep.web.cern.ch/proj-clhep/dist1/clhep-${version}.tgz";
        hash = "sha256-HIMEp3cqxrmRlfEwA3jG4930rQfIXWSgRQVlKruKVfk=";
      };
    }
  );

  epic = callPackage pkgs/epic { inherit epic-src; };

  edm4eic = callPackage pkgs/edm4eic { inherit edm4eic-src; };

  edm4hep = callPackage pkgs/edm4hep { inherit edm4hep-src; };

  eicrecon = callPackage pkgs/eicrecon { inherit eicrecon-src; };

  eic-smear = callPackage pkgs/eic-smear {};

  # Required by a recent EICrecon
  fmt = if final.lib.versionOlder prev.fmt.version "9" then fmt_9 else prev.fmt;
  # Also update an input hardcoded in nixpkgs' spdlog (it switched to fmt
  # later, so we'd like to stay forward-compatible)
  fmt_8 = prev.fmt_9;

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
  }).overrideAttrs (prev: rec {
    version = "11.1.3";
    src = fetchurl {
      url = "https://cern.ch/geant4-data/releases/geant4-v${version}.tar.gz";
      hash = "sha256-TF++pnidjWGe2sygYx1rUhGmDhv5l0w9P6ue+eImkvU=";
    };
    postPatch = ''
      substituteInPlace source/externals/ptl/cmake/Modules/PTLPackageConfigHelpers.cmake \
        --replace '${"$"}{prefix}/${"$"}{PTL_INSTALL_' '${"$"}{PTL_INSTALL_'
    '';
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=20"
      "-DGEANT4_BUILD_TLS_MODEL=global-dynamic"
    ];
  });

  genfit = callPackage pkgs/genfit {};

  hepmc3 = prev.hepmc3.overrideAttrs (old:
    (final.lib.optionalAttrs (final.lib.versionOlder prev.hepmc3.version "3.2.6") rec {
      version = "3.2.6";
      src = final.fetchurl {
        url = "http://hepmc.web.cern.ch/hepmc/releases/HepMC3-${version}.tar.gz";
        hash = "sha256-JI87WzbddzhEy+c9UfYIkUWDNLmGsll1TFnb9Lvx1SU=";
      };
    }) // {
      postPatch = old.postPatch or "" + ''
        substituteInPlace CMakeLists.txt \
          --replace 'SET(CMAKE_INSTALL_RPATH "''${CMAKE_INSTALL_PREFIX}/''${CMAKE_INSTALL_LIBDIR}")' \
                    'SET(CMAKE_INSTALL_RPATH "''${CMAKE_INSTALL_FULL_LIBDIR}")'
      '';
      # Prevent patchelf from stripping search paths for plugins
      # (it can't see them because they are dlopen'ed)
      dontPatchELF = true;
    });

  irt = callPackage pkgs/irt {};

  jana2 = callPackage pkgs/jana2 { inherit jana2-src; };

  juggler = callPackage pkgs/juggler { inherit juggler-src; };

  k4FWCore = callPackage pkgs/k4FWCore {};

  npdet = callPackage pkgs/npdet {};

  npsim = callPackage pkgs/npsim {};

  llvm_13 = prev.llvm_13.overrideAttrs (prev: {
    patches = (prev.patches or []) ++ [
      # Fix compilation with C++20 for clang
      (final.fetchpatch {
        url = "https://github.com/llvm/llvm-project/commit/a2ac383b44172ec47e4086d7572597ab251a4793.diff";
        hash = "sha256-PoqxmQsIkrCyvvdFvkuEof+C3HWOjgGFRUfvVlZYPsI=";
        stripLen = 1;
      })
    ];
  });

  root = prev.root.overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=20"
      "-Dssl=ON" # for Gaudi
      "-Dbuiltin_unuran=ON"
      "-Dpythia6=ON" # for fun4all
      "-Dunuran=ON" # for sartre
      "-Droot7=ON" "-Dwebgui=ON" "-Dbuiltin_openui5=ON" # ROOT::ROOTGeomViewer for dd4hep
    ] ++ final.lib.optionals final.stdenv.isDarwin [
      # https://github.com/AIDASoft/podio/issues/367
      "-Dimt=OFF"
    ];
    preConfigure = builtins.replaceStrings [ "rm -rf builtins/*" ] [ "" ] prev.preConfigure;
    buildInputs  = prev.buildInputs ++ [
      openssl
      pythia6
    ] ++ final.lib.optionals final.stdenv.isDarwin [
      memorymappingHook # for roofit/xroofit/src/xRooNLLVar.cxx
    ];
  });

  dd4hep = callPackage pkgs/dd4hep {
    inherit dd4hep-src;
    inherit (darwin.apple_sdk.frameworks) AGL OpenGL;
  };

  podio = callPackage pkgs/podio { inherit podio-src; };

  pythia6 = callPackage pkgs/pythia6 {};

  rave = callPackage pkgs/rave {};

  sartre = callPackage pkgs/sartre {};

  veccore = callPackage pkgs/veccore {};

  vecgeom = callPackage pkgs/vecgeom {};

}
