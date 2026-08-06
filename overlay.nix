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
, irt2-src
, jana2-src
, juggler-src
, npsim-src
, eic-rucio-policy-package-src
, osg-ca-certs-src
, podio-src
, ...
}:

final: prev: with final; {

  acts = callPackage pkgs/acts { inherit acts-src; };

  algorithms = callPackage pkgs/algorithms { inherit algorithms-src; };

  afterburner = callPackage pkgs/afterburner {};

  aida = callPackage pkgs/aida {};

  cgal_4 = callPackage pkgs/cgal/4.nix {};

  epic = callPackage pkgs/epic {
    inherit epic-src epic-calibrations-cache;
  };

  epic-calibrations-cache = import pkgs/epic/calibrations-cache.nix {
    lib = final.lib;
    stdenv = final.stdenv;
    inherit epic-src;
    curl = final.curl;
    cacert = final.cacert;
    python3 = final.python3;
  };

  edm4eic = callPackage pkgs/edm4eic { inherit edm4eic-src; };

  edm4hep = callPackage pkgs/edm4hep { inherit edm4hep-src; };

  eicrecon = callPackage pkgs/eicrecon { inherit eicrecon-src; };

  eic-smear = callPackage pkgs/eic-smear {};

  eic-rucio-policy-package = callPackage pkgs/eic-rucio-policy-package {
    inherit eic-rucio-policy-package-src;
  };

  rucio-etc = callPackage pkgs/rucio-etc {};

  gaudi = callPackage pkgs/gaudi {};

  geant4 = (prev.geant4.override {
    enableQt = true;
  }).overrideAttrs (prev: rec {
    version = "11.4.1";
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

  irt2 = callPackage pkgs/irt2 { inherit irt2-src; };

  jana2 = callPackage pkgs/jana2 { inherit jana2-src; };

  juggler = callPackage pkgs/juggler { inherit juggler-src; };

  k4FWCore = callPackage pkgs/k4FWCore {};

  npsim = callPackage pkgs/npsim { inherit npsim-src; };

  #llvm_20 = null;
  llvm_20 = prev.llvm_20.overrideAttrs (prev: {
    patches = prev.patches ++ [
      (fetchpatch2 {
        url = "https://github.com/llvm/llvm-project/pull/169772.diff";
        stripLen = 1;
        hash = "sha256-tR2gmdp0jcuLjBmoNZHJfrgkRWfZy/SuE350qUGiSyM=";
      })
    ];
  });

  root = prev.root.overrideAttrs (self: {
    patches = [
      (fetchpatch2 {
        url = "https://github.com/root-project/root/pull/22457.patch";
        hash = "sha256-X5TLNRG2Lu4lQCfm7gHZF4Iyjq6NzmmyfZDuAo5uvBs=";
      })
    ];
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

  rucio = prev.rucio.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      install -Dm755 -t $out/bin $src/bin/*
    '';
  });

  dd4hep = callPackage pkgs/dd4hep {
    inherit dd4hep-src;
  };

  osg-ca-certs = callPackage pkgs/osg-ca-certs {
    inherit osg-ca-certs-src;
  };

  podio = callPackage pkgs/podio { inherit podio-src; };

  sio = callPackage pkgs/sio {};

  veccore = callPackage pkgs/veccore {};

  vecgeom = callPackage pkgs/vecgeom {};

}
