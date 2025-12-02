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
    postPatch = ''
      substituteInPlace source/externals/ptl/cmake/Modules/PTLPackageConfigHelpers.cmake \
        --replace-warn '${"$"}{prefix}/${"$"}{PTL_INSTALL_' '${"$"}{PTL_INSTALL_'
    '';
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=20"
      "-DGEANT4_BUILD_TLS_MODEL=global-dynamic"
    ];
    meta.broken = false;
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
      "-Droot7=ON" "-Dwebgui=ON" "-Dbuiltin_openui5=ON" # ROOT::ROOTGeomViewer for dd4hep
    ] ++ final.lib.optionals final.stdenv.isDarwin [
      # https://github.com/AIDASoft/podio/issues/367
      "-Dimt=OFF"
    ];
    env.NIX_LDFLAGS = lib.optionalString (!stdenv.isDarwin) "--version-script,${./pkgs/root/version.map}";
    env.CXXFLAGS = lib.optionalString stdenv.isDarwin "-faligned-allocation";
    preConfigure = builtins.replaceStrings [ "rm -rf builtins/*" ] [ "" ] prev.preConfigure;
    buildInputs  = prev.buildInputs ++ [
      openssl
    ];
  });

  dd4hep = callPackage pkgs/dd4hep {
    inherit dd4hep-src;
  };

  onnxruntime = prev.onnxruntime.overrideAttrs (old: let
    eigen = fetchFromGitLab {
      owner = "libeigen";
      repo = "eigen";
      # https://github.com/microsoft/onnxruntime/blob/v1.16.3/cgmanifests/cgmanifest.json#L571
      rev = "e7248b26a1ed53fa030c5c459f7ea095dfd276ac";
      hash = "sha256-uQ1YYV3ojbMVfHdqjXRyUymRPjJZV3WHT36PTxPRius=";
    };

    onnx = fetchFromGitHub {
      owner = "onnx";
      repo = "onnx";
      rev = "refs/tags/v1.14.1";
      hash = "sha256-ZVSdk6LeAiZpQrrzLxphMbc1b3rNUMpcxcXPP8s/5tE=";
    };
  in final.lib.optionalAttrs (final.lib.versionOlder prev.onnxruntime.version "1.16") rec {
    version = "1.16.3";

    src = fetchFromGitHub {
      owner = "microsoft";
      repo = "onnxruntime";
      rev = "refs/tags/v${version}";
      hash = "sha256-bTW9Pc3rvH+c8VIlDDEtAXyA3sajVyY5Aqr6+SxaMF4=";
      fetchSubmodules = true;
    };

    cmakeFlags = old.cmakeFlags ++ [
      "-DFETCHCONTENT_SOURCE_DIR_EIGEN=${eigen}"
      "-DFETCHCONTENT_SOURCE_DIR_ONNX=${onnx}"
    ];

    # https://github.com/microsoft/onnxruntime/issues/13225
    postPatch = (old.postPatch or "") + lib.optionalString stdenv.isDarwin ''
      sed \
        -i onnxruntime/test/framework/inference_session_test.cc \
        -e '/InterThreadPoolWithDenormalAsZero/areturn;'
    '';
  });

  opencascade-occt = prev.opencascade-occt.overrideAttrs (old:
    final.lib.optionalAttrs ((final.lib.versionOlder prev.opencascade-occt.version "7.8.2") && (prev.opencascade-occt.patches or [] == [])) rec {
      patches = [
        (final.fetchpatch {
          url = "https://github.com/Open-Cascade-SAS/OCCT/commit/7236e83dcc1e7284e66dc61e612154617ef715d6.diff";
          hash = "sha256-NoC2mE3DG78Y0c9UWonx1vmXoU4g5XxFUT3eVXqLU60=";
        })
      ];
    }
  );

  osg-ca-certs = callPackage pkgs/osg-ca-certs {};

  podio = callPackage pkgs/podio { inherit podio-src; };

  veccore = callPackage pkgs/veccore {};

  vecgeom = callPackage pkgs/vecgeom {};

  # Fix "Could not load a local code page transcoder"
  xercesc = prev.xercesc.overrideAttrs (old: {
    buildInputs = [
      icu
    ];
    configureFlags = old.configureFlags ++ [
      "--enable-transcoder-icu"
    ];
  });

}
