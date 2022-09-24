{ lib
, stdenv
, runCommandNoCC
, fetchFromGitHub
, fetchurl
, fetchpatch
, symlinkJoin
, acts
, autoreconfHook
, boost
, clhep
, cgal, gmp, mpfr
, cmake
, dd4hep
, e2fsprogs # provides libuuid on macOS
, eigen
, eic-smear
, fastjet
, fastjet-contrib
, geant4
, genfit
, gfortran
, gsl
, hepmc2
, log4cpp
, libuuid
, pythia6
, pythia
, rave
, root
, sartre
, tbb
, unixODBC
, vc_0_7
, xercesc
}:

let

  /* Merge lists of attrsets by merging list values and overriding all others.

     Example:
       update_attrs [ { a=[1]; } { b=2; } { a=[5]; b=7; } ]
       => { a = [ 1 5 ]; b = 7; }
  */
  update_attrs =
    builtins.zipAttrsWith (name: values: if builtins.isList (builtins.elemAt values 0) then builtins.concatLists values else lib.last values);

  mk_path = path: args: stdenv.mkDerivation (update_attrs [ rec {
    pname = "fun4all_coresoftware_${builtins.replaceStrings [ "/" ] [ "_" ] path}";
    version = "unstable-2022-01-28";

    src = fetchFromGitHub {
      owner = "eic";
      repo = "fun4all_coresoftware";
      rev = "71e7c8a84fffa612341dc4591022a5b800d67286";
      hash = "sha256-INYUqayht1lfeMcHfKDz0Qz4wJb8JRp93p060t78cXE=";
    };

    buildInputs = [
      autoreconfHook
      root
    ];

    NIX_CFLAGS_COMPILE =
      lib.optionals stdenv.isDarwin [ "-DBOOST_STACKTRACE_GNU_SOURCE_NOT_REQUIRED" ];

    preAutoreconf = ''
      cd ${path}
    '';

    postInstall = lib.optionalString stdenv.isDarwin ''
      (
      cd "$out"/lib
      for lib in *.dylib; do
        ln -s $lib ''${lib%%.dylib}.so
      done
      )
    '';

    meta = with lib; {
      description = "Fun4All reconstruciton framework";
      license = licenses.unfree; # no license
      homepage = "https://github.com/sPHENIX-Collaboration/coresoftware";
      platforms = platforms.unix;
      maintainers = with maintainers; [ veprbl ];
    };
  } args ]);

  mk_path_eicdetectors = path: args: mk_path path (args // {
    pname = "fun4all_eicdetectors_${builtins.replaceStrings [ "/" ] [ "_" ] path}";
    version = "unstable-2022-06-28";

    src = fetchFromGitHub {
      owner = "eic";
      repo = "fun4all_eicdetectors";
      rev = "5cbc98af36a95ed3593811cbc6c20a42a0b0f86e";
      hash = "sha256-6mMdIKumIAa7poZkOzV99DBoeX5YymnOxsDVA7F17Jc=";
    };
  });

  mk_path_ecce-detectors = path: args: mk_path path (args // {
    pname = "ecce-detectors_${builtins.replaceStrings [ "/" ] [ "_" ] path}";
    version = "unstable-2022-09-30";

    src = fetchFromGitHub {
      owner = "ECCE-EIC";
      repo = "ecce-detectors";
      rev = "96590d20d9cdc6412f72b5ed4ae0abf56d6518dd";
      hash = "sha256-prjIadj643hEiSIhaKGgUJs8MqlwFaK/bxg1WVseQqc=";
    };
  });

    genfit_includes = runCommandNoCC "genfit-includes" {} ''
      mkdir -p "$out/include"
      ln -s "${genfit}/include" "$out/include/GenFit"
    '';

  acts_orig = acts;

  extra_deps = rec {
    libodbcxx = stdenv.mkDerivation rec {
      pname = "libodbc++";
      version = "0.2.5";

      src = fetchurl {
        url = "mirror://sourceforge/libodbcxx/libodbc%2B%2B/0.2.5/libodbc%2B%2B-0.2.5.tar.bz2";
        hash = "sha256-ujAwons05Kr77Oyi3bv0KjiBXpU080wFFiBUBTG14j4=";
      };

      propagatedBuildInputs = [
        unixODBC
      ];

      postPatch = ''
        substituteInPlace src/dtconv.h \
          --replace ODBCXX_STRING_PERCENT '"%"'
      '';

      meta.license = lib.licenses.lgpl2Only;
    };
    inherit clhep;

    acts = acts_orig.overrideAttrs (prev: rec {
      version = "sPHENIX-unstable-2021-07-30";

      src = fetchFromGitHub {
        owner = "sPHENIX-Collaboration";
        repo = "acts";
        rev = "61e78df874d793e0f2c6db949d9e485876a3ad02";
        hash = "sha256-8TYw6XZfSmJ1v1WlMI2eY8t/fO5+exPwM999qziPa6Q=";
      };

      buildInputs = [
        boost
        dd4hep
        tbb
      ];

      cmakeFlags = prev.cmakeFlags ++ [
        "-DACTS_BUILD_EXAMPLES=ON"
      ];
    });

    BeastMagneticField = stdenv.mkDerivation rec {
      pname = "BeastMagneticField";
      version = "unstable-2021-10-01";

      src = fetchFromGitHub {
        owner = "eic";
        repo = pname;
        rev = "0f089e5213901b597fe9b2f969eb1910c073aba0";
        hash = "sha256-PyVFLFGfaxGCNVnPBqc4ilgX2W1khc/XXx5yEZj/JGo=";
      };

      nativeBuildInputs = [
        cmake
      ];
      buildInputs = [
        root
      ];

      cmakeFlags = [
        "-DCMAKE_CXX_STANDARD=17" # required by a recent ROOT
      ];

      meta.license = lib.licenses.unfree; # no license
    };

    geant4_10_6_2 = geant4.overrideAttrs (prev: rec {
      version = "10.6.2";

      src = fetchurl{
        url = "https://geant4-data.web.cern.ch/geant4-data/releases/geant4.10.06.p02.tar.gz";
        hash = "sha256-7Nrb+EaAevi6oHHzgQT7DcwkhHyEdc2DlzAuKu+o9m8=";
      };

      postPatch = (prev.postPatch or "") + ''
        substituteInPlace cmake/Modules/FindXQuartzGL.cmake \
          --replace "NO_DEFAULT_PATH" ""

        # A workaround for
        #   error: ambiguating new declaration of
        # with modern gcc/glibc
        substituteInPlace source/persistency/ascii/src/G4tgrEvaluator.cc \
          --replace fsqrt _fsqrt
      '';
    });

    KFParticle = stdenv.mkDerivation rec {
      pname = "KFParticle";
      version = "unstable-2022-01-26";

      src = fetchFromGitHub {
        owner = "sPHENIX-Collaboration";
        repo = pname;
        rev = "325f00ae2612d2cf0e45b9d7c3e33b4f2cfe84a9";
        hash = "sha256-uj3gaq41qCifX+u74eNjqMKCBt0d4BVCwtILwHDRcCo=";
      };

      nativeBuildInputs = [ cmake ];
      propagatedBuildInputs = [ vc_0_7 ];
      buildInputs = [ root ];

      meta.license = lib.licenses.gpl3Only;
    };

    uuid = if stdenv.isDarwin then e2fsprogs else libuuid;
  };

sphenix_packages = with extra_deps; let geant4 = extra_deps.geant4_10_6_2; in rec {
  generators.FermiMotionAfterburner = mk_path "generators/FermiMotionAfterburner" {
    buildInputs = [ gsl generators.phhepmc offline.framework.fun4all offline.framework.phool ];
  };
  generators.flowAfterburner = mk_path "generators/flowAfterburner" {
    buildInputs = [ boost clhep gsl hepmc2 offline.framework.phool ];
  };
  generators.phhepmc = mk_path "generators/phhepmc" {
    propagatedBuildInputs = [ clhep gsl hepmc2 ];
    buildInputs = [ boost generators.flowAfterburner offline.framework.frog offline.framework.fun4all offline.framework.phool ];
    OFFLINE_MAIN = hepmc2;
  };
  generators.PHPythia6 = mk_path "generators/PHPythia6" {
    buildInputs = [ cgal fastjet generators.phhepmc offline.framework.fun4all offline.framework.phool ];
  };
  generators.PHPythia8 = mk_path "generators/PHPythia8" {
    buildInputs = [ boost fastjet pythia generators.phhepmc offline.framework.fun4all offline.framework.phool ];
  };
  generators.PHSartre = mk_path "generators/PHSartre" {
    buildInputs = [ sartre generators.phhepmc offline.framework.fun4all ];
    # ./libtool: line 7753: cd: lib: No such file or directory
    preBuild = ''
      mkdir lib
    '';
  };
  offline.packages.intt = mk_path "offline/packages/intt" {
    buildInputs = [ extra_deps.acts boost clhep offline.framework.fun4all offline.framework.phool offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  offline.framework.phool = mk_path "offline/framework/phool" {
    buildInputs = [ boost ];
    propagatedBuildInputs = [ log4cpp ];
  };
  offline.framework.ffaobjects = mk_path "offline/framework/ffaobjects" {
    buildInputs = [ offline.framework.phool ];
    CXXFLAGS = lib.optionals stdenv.cc.isGNU [ "-Wno-error=deprecated-copy" ];
  };
  offline.framework.frog = mk_path "offline/framework/frog" {
    buildInputs = [ boost libodbcxx offline.framework.phool ];
  };
  offline.framework.fun4all = mk_path "offline/framework/fun4all" {
    buildInputs = [ boost offline.framework.ffaobjects offline.framework.frog offline.framework.phool ];
  };
  offline.database.pdbcal.base = mk_path "offline/database/pdbcal/base" {
    buildInputs = [ boost offline.framework.phool ];
    postPatch = ''
      substituteInPlace offline/database/pdbcal/base/PdbParameterMap.h \
        --replace "std::map<const " "std::map<"
      substituteInPlace offline/database/pdbcal/base/PdbParameterMap.cc \
        --replace "map<const " "map<"
    '';
  };
  offline.database.PHParameter = mk_path "offline/database/PHParameter" {
    buildInputs = [ boost offline.database.pdbcal.base offline.framework.phool ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
    postPatch = ''
      substituteInPlace offline/database/PHParameter/Makefile.am \
        --replace "-lstdc++fs" ""
      substituteInPlace offline/database/PHParameter/PHParameters.h \
        --replace "std::map<const " "std::map<"
      substituteInPlace offline/database/PHParameter/PHParameters.cc \
        --replace "std::map<const " "std::map<"
    '';
  };
  offline.packages.CaloBase = mk_path "offline/packages/CaloBase" {
    propagatedBuildInputs = [ clhep offline.framework.phool ];
    buildInputs = [ offline.framework.fun4all ];
  };
  offline.packages.CaloReco = mk_path "offline/packages/CaloReco" {
    buildInputs = [ boost gsl offline.database.PHParameter offline.framework.fun4all offline.packages.CaloBase /*offline.packages.NodeDump*/ simulation.g4simulation.g4vertex ];
  };
  offline.packages.centrality = mk_path "offline/packages/centrality" {
    buildInputs = [ offline.framework.phool ];
  };
  offline.packages.Half = mk_path "offline/packages/Half" {
    CXXFLAGS = lib.optionals stdenv.cc.isGNU [ "-Wno-error=deprecated-copy" ];
  };
  offline.packages.HelixHough = mk_path "offline/packages/HelixHough" {
    buildInputs = [ eigen offline.packages.trackbase ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
  };
  offline.packages.jetbackground = mk_path "offline/packages/jetbackground" {
    buildInputs = [ cgal fastjet fastjet-contrib offline.framework.fun4all offline.framework.phool offline.packages.CaloBase simulation.g4simulation.g4jets simulation.g4simulation.g4main ];
  };
  offline.packages.KFParticle_sPHENIX = mk_path "offline/packages/KFParticle_sPHENIX" {
    propagatedBuildInputs = [ KFParticle ];
    buildInputs = [ generators.phhepmc offline.framework.ffaobjects offline.framework.fun4all offline.framework.phool offline.packages.CaloBase offline.packages.intt offline.packages.mvtx offline.packages.tpc offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4eval simulation.g4simulation.g4main ];
    postPatch = ''
      sed -i offline/packages/KFParticle_sPHENIX/KFParticle_particleList.h \
        -e "1i#include <string>"
    '';
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  offline.packages.micromegas = mk_path "offline/packages/micromegas" {
    buildInputs = [ clhep offline.framework.fun4all offline.framework.phool offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  offline.packages.mvtx = mk_path "offline/packages/mvtx" {
    buildInputs = [ clhep boost offline.framework.fun4all offline.framework.phool offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  offline.packages.particleflow = mk_path "offline/packages/particleflow" {
    buildInputs = [ gsl offline.framework.fun4all offline.framework.phool offline.packages.CaloBase simulation.g4simulation.g4jets simulation.g4simulation.g4main ];
  };
  offline.packages.PHGeometry = mk_path "offline/packages/PHGeometry" {
    buildInputs = [ uuid offline.framework.fun4all offline.framework.phool ];
  };
  offline.packages.PHField = mk_path "offline/packages/PHField" {
    buildInputs = [ boost BeastMagneticField clhep geant4 offline.framework.fun4all offline.framework.phool ];
  };
  offline.packages.PHGenFitPkg.GenFitExp = mk_path "offline/packages/PHGenFitPkg/GenFitExp" {
    buildInputs = [ clhep genfit genfit_includes offline.packages.PHField ];
  };
  offline.packages.PHGenFitPkg.PHGenFit = mk_path "offline/packages/PHGenFitPkg/PHGenFit" {
    postPatch = ''
      ln -s ./ offline/packages/PHGenFitPkg/PHGenFit/phgenfit
    '';
    NIX_CFLAGS_COMPILE = [ "-Wno-nonportable-include-path" ];
    buildInputs = [ genfit offline.packages.PHGenFitPkg.GenFitExp offline.packages.PHField offline.packages.trackbase ];
    propagatedBuildInputs = [ genfit_includes ];
  };
  offline.packages.tpc = mk_path "offline/packages/tpc" {
    postPatch = ''
      ln -s ./ offline/packages/tpc/tpc
    '';
    buildInputs = [ offline.framework.fun4all offline.framework.phool offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  offline.packages.trackbase = mk_path "offline/packages/trackbase" {
#    patches = [
#      # trackbase compilation with new acts
#      (fetchpatch {
#        url = "https://github.com/sPHENIX-Collaboration/coresoftware/commit/2d004b1fa4ebb9eee73e38919e4876c96cbf14d0.diff";
#        hash = "sha256-BNxiErPORQ2cqiehiiOfp0TFIeJsbrw22+wuqEvPbLE=";
#        excludes = [ "offline/packages/trackbase_historic/*" ];
#      })
#    ];
    propagatedBuildInputs = [ extra_deps.acts ];
    buildInputs = [ offline.framework.phool ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
    postPatch = ''
      # resolve include for g4main (possibly others)
      export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$PWD/simulation/g4simulation
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $PWD/simulation/g4simulation"

      # resolve include for trackbase (possibly others)
      export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$PWD/offline/packages
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $PWD/offline/packages"
    '';
  };
  offline.packages.trackbase_historic = mk_path "offline/packages/trackbase_historic" {
#    patches = [
#      (fetchpatch {
#        url = "https://github.com/sPHENIX-Collaboration/coresoftware/commit/9b11e8730e1e1f4dcb36173f387408aae04b64d2.diff";
#        hash = "sha256-KtRphMQJole1eEWGoBX/GKqpmiW8yvxHT0iV7SiEFwY=";
#      })
#      # trackbase compilation with new acts
#      (fetchpatch {
#        url = "https://github.com/sPHENIX-Collaboration/coresoftware/commit/2d004b1fa4ebb9eee73e38919e4876c96cbf14d0.diff";
#        hash = "sha256-cPROocTsthiG0GUrDJKEqu/aA0IKagNsZYb4Qi46KyQ=";
#        excludes = [ "offline/packages/trackbase/*" ];
#      })
#    ];
    postPatch = ''
      # resolve include for g4main (possibly others)
      export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$PWD/simulation/g4simulation
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $PWD/simulation/g4simulation"
    '';
    buildInputs = [ extra_deps.acts boost offline.framework.phool offline.packages.trackbase ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  offline.packages.trackreco = mk_path "offline/packages/trackreco" {
#    patches = [
#      # update acts evaluator
#      (fetchpatch {
#        url = "https://github.com/sPHENIX-Collaboration/coresoftware/commit/60e90583a30a54f851acf4851cf39d25896382e4.diff";
#        hash = "sha256-xv+gXHcn+wHG5nriqI1/BHwFUfCmdXtNgG4M/EWSEZQ=";
#      })
#    ];
    postPatch = ''
      # resolve include for g4main (possibly others)
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $PWD/simulation/g4simulation"

      #      # resolve include for intt (possibly others)
      #      export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$PWD/offline/packages
      #      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $PWD/offline/packages"

      substituteInPlace offline/packages/trackreco/ActsEvaluator.cc \
        --replace "trackKeyMap = m_actsTrackKeyMap->find(trackKey)->second;" \
                  "{ std::map<const size_t, const unsigned int> c = m_actsTrackKeyMap->find(trackKey)->second; trackKeyMap.swap(c); }"

      substituteInPlace offline/packages/trackreco/PHRTreeSeeding.cc \
        --replace "std::bind2nd(std::minus<double>(), phi_mean)" "std::bind(std::minus<double>(), std::placeholders::_1, phi_mean)" \
        --replace "std::bind2nd(std::minus<double>(), z_mean)" "std::bind(std::minus<double>(), std::placeholders::_1, z_mean)" \
        --replace "std::bind2nd(std::minus<double>(), curv_mean)" "std::bind(std::minus<double>(), std::placeholders::_1, curv_mean)"

      substituteInPlace offline/packages/trackreco/Makefile.am \
        --replace "-lg4testbench" ""
    '' + simulation.g4simulation.g4main.postPatch;
    buildInputs = [
      extra_deps.acts boost clhep geant4 genfit gsl rave offline.framework.fun4all offline.framework.phool offline.packages.HelixHough /*offline.packages.intt*/ offline.packages.PHGenFitPkg.GenFitExp offline.packages.PHGenFitPkg.PHGenFit offline.packages.PHGeometry offline.database.PHParameter offline.packages.trackbase offline.packages.trackbase_historic
    offline.packages.PHField simulation.g4simulation.g4eval simulation.g4simulation.g4detectors offline.packages.tpc simulation.g4simulation.g4bbc offline.packages.intt offline.packages.mvtx offline.packages.micromegas offline.packages.CaloBase simulation.g4simulation.g4intt simulation.g4simulation.g4tpc simulation.g4simulation.g4mvtx
    ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  offline.packages.trigger = mk_path "offline/packages/trigger" {
    buildInputs = [ offline.framework.fun4all offline.framework.phool offline.packages.CaloBase ];
  };
  offline.packages.vararray = mk_path "offline/packages/vararray" {
    buildInputs = [ offline.framework.phool offline.packages.Half ];
  };
  offline.QA.modules = mk_path "offline/QA/modules" {
    buildInputs = [ boost generators.phhepmc offline.framework.fun4all offline.packages.intt offline.framework.phool offline.packages.CaloBase offline.packages.KFParticle_sPHENIX offline.packages.micromegas offline.packages.mvtx offline.packages.tpc offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4eval simulation.g4simulation.g4jets simulation.g4simulation.g4main ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  simulation.g4simulation.g4bbc = mk_path "simulation/g4simulation/g4bbc" {
    buildInputs = [ gsl offline.framework.fun4all offline.framework.phool simulation.g4simulation.g4detectors ];
    postPatch = ''
      # resolve include for g4main (possibly others)
      export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$PWD/simulation/g4simulation
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $PWD/simulation/g4simulation"
    '';
  };
  simulation.g4simulation.g4decayer = mk_path "simulation/g4simulation/g4decayer" {
    buildInputs = [ geant4 pythia6 ];
  };
  simulation.g4simulation.g4detectors = mk_path "simulation/g4simulation/g4detectors" {
    buildInputs = [ boost cgal gmp mpfr geant4 gsl offline.database.pdbcal.base offline.database.PHParameter offline.framework.phool offline.framework.fun4all simulation.g4simulation.g4main ];
    postPatch = ''
      substituteInPlace simulation/g4simulation/g4detectors/Makefile.am \
        --replace "-lphg4gdml" ""

      # resolve include for g4main (possibly others)
      export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$PWD/simulation/g4simulation
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $PWD/simulation/g4simulation"
    '' + simulation.g4simulation.g4main.postPatch;
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  simulation.g4simulation.EICPhysicsList = mk_path "simulation/g4simulation/EICPhysicsList" {
    buildInputs = [ clhep geant4 ];
    # /nix/store/<hash>-geant4-11.0.0/include/Geant4/PTL/Globals.hh:33:10: fatal error: 'PTL/Types.hh' file not found
    NIX_CFLAGS_COMPILE = [ "-isystem ${geant4}/include/Geant4" ];
  };
  simulation.g4simulation.g4calo = mk_path "simulation/g4simulation/g4calo" {
    buildInputs = [ boost gsl offline.database.pdbcal.base offline.database.PHParameter offline.framework.fun4all offline.packages.CaloBase simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  simulation.g4simulation.g4dst = mk_path "simulation/g4simulation/g4dst" {
    buildInputs = [ generators.phhepmc offline.framework.ffaobjects offline.packages.CaloBase offline.packages.centrality offline.packages.jetbackground offline.packages.KFParticle_sPHENIX offline.packages.particleflow offline.packages.PHGeometry offline.packages.PHField offline.packages.tpc offline.packages.trackbase_historic offline.packages.trackreco offline.packages.trigger offline.packages.intt offline.packages.micromegas offline.packages.mvtx simulation.g4simulation.g4bbc simulation.g4simulation.g4detectors simulation.g4simulation.g4jets simulation.g4simulation.g4intt simulation.g4simulation.g4vertex simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4eval = mk_path "simulation/g4simulation/g4eval" {
    buildInputs = [ boost hepmc2 generators.phhepmc offline.framework.fun4all offline.packages.intt offline.framework.phool offline.packages.CaloBase offline.packages.micromegas offline.packages.mvtx offline.packages.tpc offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4jets simulation.g4simulation.g4main simulation.g4simulation.g4vertex ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
  };
  simulation.g4simulation.g4gdml = mk_path "simulation/g4simulation/g4gdml" {
    buildInputs = [ geant4 xercesc offline.framework.fun4all offline.framework.phool ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
    patches = lib.optionals (lib.versionAtLeast geant4.version "11.0.0") [
      (fetchpatch {
        url = "https://github.com/sPHENIX-Collaboration/coresoftware/commit/623f4513ea8f925e1076ba5a437b63a06f3b0e95.diff";
        hash = "sha256-YpMW4IO0lQ+XLakb688dVgI5sm8ILTpnvXOrajOBxaI=";
      })
    ];
  };
  simulation.g4simulation.g4intt = mk_path "simulation/g4simulation/g4intt" {
    buildInputs = [ boost offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.intt offline.packages.trackbase simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4jets = mk_path "simulation/g4simulation/g4jets" {
    buildInputs = [ cgal fastjet fastjet-contrib generators.phhepmc offline.framework.fun4all offline.framework.phool offline.packages.CaloBase offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4vertex simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4main = mk_path "simulation/g4simulation/g4main" {
    propagatedBuildInputs = [ clhep geant4 gsl ]; # offline.framework.fun4all
    buildInputs = [ boost eigen eic-smear offline.database.PHParameter simulation.g4simulation.EICPhysicsList simulation.g4simulation.g4decayer simulation.g4simulation.g4gdml offline.framework.frog offline.framework.phool offline.framework.ffaobjects offline.framework.fun4all /*offline.packages.CaloReco*/ offline.packages.PHGeometry offline.packages.PHField offline.packages.vararray generators.phhepmc ];
    postPatch = ''
      sed -i simulation/g4simulation/g4main/PHG4Hit.h -e '1i#if !defined(ULONG_LONG_MAX)' -e '1i#define ULONG_LONG_MAX 18446744073709551615ULL' -e '1i#endif'
      substituteInPlace simulation/g4simulation/g4main/PHG4HitDefs.cc \
        --replace "<tr1/functional>" "<functional>" \
        --replace "std::tr1" "std"
    '';
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
  };
  simulation.g4simulation.g4mvtx = mk_path "simulation/g4simulation/g4mvtx" {
    buildInputs = [ boost offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.mvtx offline.packages.trackbase simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4tpc = mk_path "simulation/g4simulation/g4tpc" {
    buildInputs = [ boost offline.database.pdbcal.base offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.tpc offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    CXXFLAGS = lib.optionals (lib.versionOlder geant4.version "11.0.0") [ "-std=c++17" ];
    NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
  };
  simulation.g4simulation.g4trackfastsim = mk_path "simulation/g4simulation/g4trackfastsim" {
    buildInputs = [ gsl offline.database.pdbcal.base offline.framework.fun4all offline.framework.phool offline.packages.CaloBase offline.packages.PHField offline.packages.PHGenFitPkg.PHGenFit offline.packages.PHGeometry offline.database.PHParameter offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4vertex = mk_path "simulation/g4simulation/g4vertex" {
    buildInputs = [ extra_deps.acts gsl offline.framework.fun4all offline.framework.phool offline.packages.trackbase_historic simulation.g4simulation.g4bbc simulation.g4simulation.g4detectors ];
    postPatch = ''
      # resolve include for g4main (possibly others)
      export ROOT_INCLUDE_PATH=$ROOT_INCLUDE_PATH:$PWD/simulation/g4simulation
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -isystem $PWD/simulation/g4simulation"
    '';
  };

  analysis.eicevaluator = mk_path_eicdetectors "analysis/eicevaluator" {
    buildInputs = [ hepmc2 generators.phhepmc offline.framework.fun4all offline.framework.phool offline.packages.CaloBase offline.packages.mvtx offline.packages.trackbase offline.packages.trackbase_historic reconstruction.eicpidbase simulation.g4simulation.g4detectors simulation.g4simulation.g4eval simulation.g4simulation.g4jets simulation.g4simulation.g4main simulation.g4simulation.g4vertex ];
    postPatch = ''
      echo 'template int GetParameterFromFile<>(std::string filename, std::string param);' \
        >> analysis/eicevaluator/FarForwardEvaluator.cc
    '';
  };
  reconstruction.eiccaloreco = mk_path_eicdetectors "reconstruction/eiccaloreco" {
    buildInputs = [ gsl offline.database.PHParameter offline.framework.fun4all offline.packages.CaloBase simulation.g4simulation.g4vertex ];
    postPatch = ''
      substituteInPlace reconstruction/eiccaloreco/RawClusterBuilderkV3.h \
        --replace "<RawClusterBuilderHelper.h>" "\"RawClusterBuilderHelper.h\""
      substituteInPlace reconstruction/eiccaloreco/RawClusterBuilderkMA.h \
        --replace "<RawClusterBuilderHelper.h>" "\"RawClusterBuilderHelper.h\""
    '';
  };
  reconstruction.eicpidbase = mk_path_eicdetectors "reconstruction/eicpidbase" {
    buildInputs = [ boost offline.framework.phool offline.packages.trackbase_historic ];
    # FIXME postInstall
    postFixup = ''
      ln -s "$out/include/eicpidbase/"* "$out/include/"
    '';
  };
  reconstruction.eiczdcbase = mk_path_eicdetectors "reconstruction/eiczdcbase" {
    buildInputs = [ offline.framework.phool ];
    NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isClang [ "-Wno-error=unused-private-field" ];
  };
  simulation.g4simulation.g4b0 = mk_path_eicdetectors "simulation/g4simulation/g4b0" {
    buildInputs = [ analysis.eicevaluator offline.database.pdbcal.base offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.CaloBase offline.packages.trackbase offline.packages.trackbase_historic offline.packages.PHField offline.packages.PHGenFitPkg.PHGenFit offline.packages.PHGeometry simulation.g4simulation.g4detectors simulation.g4simulation.g4eval simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4b0ecal = mk_path_eicdetectors "simulation/g4simulation/g4b0ecal" {
    buildInputs = [ analysis.eicevaluator offline.database.pdbcal.base offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.CaloBase simulation.g4simulation.g4eval simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4barrelmmg = mk_path_eicdetectors "simulation/g4simulation/g4barrelmmg" {
    buildInputs = [ boost offline.database.PHParameter offline.framework.fun4all offline.framework.phool simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4bwd = mk_path_eicdetectors "simulation/g4simulation/g4bwd" {
    buildInputs = [ offline.database.pdbcal.base offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.CaloBase simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isClang [ "-Wno-error=unused-private-field" ];
  };
  simulation.g4simulation.g4drcalo = mk_path_eicdetectors "simulation/g4simulation/g4drcalo" {
    buildInputs = [ extra_deps.acts boost offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.CaloBase offline.packages.trackbase_historic simulation.g4simulation.g4main simulation.g4simulation.g4detectors ];
  };
  simulation.g4simulation.g4drich = mk_path_eicdetectors "simulation/g4simulation/g4drich" {
    buildInputs = [ geant4 offline.database.PHParameter offline.framework.fun4all offline.framework.phool simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    postPatch = ''
      for file in simulation/g4simulation/g4drich/*; do
        substituteInPlace "$file" \
          --replace "#include <G4" "#include <Geant4/G4"
      done
    '';
  };
  simulation.g4simulation.g4eiccalos = mk_path_eicdetectors "simulation/g4simulation/g4eiccalos" {
    buildInputs = [ gsl extra_deps.acts offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.CaloBase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4gdml simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4eicdirc = mk_path_eicdetectors "simulation/g4simulation/g4eicdirc" {
    buildInputs = [ offline.database.PHParameter offline.framework.fun4all offline.framework.phool simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isClang [ "-Wno-error=overloaded-virtual" ];
  };
  simulation.g4simulation.g4etof = mk_path_eicdetectors "simulation/g4simulation/g4etof" {
    buildInputs = [ boost offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4lblvtx = mk_path_eicdetectors "simulation/g4simulation/g4lblvtx" {
    buildInputs = [ boost offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isClang [ "-Wno-error=unused-private-field" ];
  };
  simulation.g4simulation.g4lumi = mk_path_eicdetectors "simulation/g4simulation/g4lumi" {
    buildInputs = [ offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.CaloBase simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4mrich = mk_path_eicdetectors "simulation/g4simulation/g4mrich" {
    buildInputs = [ boost offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    postPatch = ''
      substituteInPlace simulation/g4simulation/g4mrich/PHG4mRICHSteppingAction.cc \
        --replace "!isfinite" "!std::isfinite"
    '';
  };
  simulation.g4simulation.g4rp = mk_path_eicdetectors "simulation/g4simulation/g4rp" {
    buildInputs = [ analysis.eicevaluator offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.CaloBase simulation.g4simulation.g4detectors simulation.g4simulation.g4eval simulation.g4simulation.g4main ];
    NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isClang [ "-Wno-error=unused-private-field" ];
  };
  simulation.g4simulation.g4trd = mk_path_eicdetectors "simulation/g4simulation/g4trd" {
    buildInputs = [ extra_deps.acts boost offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
  simulation.g4simulation.g4ttl = mk_path_eicdetectors "simulation/g4simulation/g4ttl" {
    buildInputs = [ offline.database.PHParameter offline.framework.fun4all offline.framework.phool offline.packages.trackbase offline.packages.trackbase_historic simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isClang [ "-Wno-error=unused-private-field" ];
  };
  simulation.g4simulation.g4zdc = mk_path_eicdetectors "simulation/g4simulation/g4zdc" {
    buildInputs = [ offline.database.PHParameter offline.framework.phool offline.framework.fun4all reconstruction.eiczdcbase simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
    NIX_CFLAGS_COMPILE = lib.optionals stdenv.cc.isClang [ "-Wno-error=unused-private-field" ];
  };

  FastPID = mk_path_ecce-detectors "FastPID" {
    buildInputs = [ offline.framework.fun4all offline.framework.phool offline.packages.trackbase offline.packages.trackbase_historic offline.packages.trackreco reconstruction.eicpidbase simulation.g4simulation.g4detectors simulation.g4simulation.g4main ];
  };
};

in

symlinkJoin {
  name = "fun4all-combined";
  paths = (lib.collect lib.isDerivation sphenix_packages) ++ [
    boost boost.dev eic-smear genfit genfit_includes gsl hepmc2 pythia6
  ] ++ (with extra_deps; [
    clhep geant4_10_6_2
  ]);
  passthru = sphenix_packages // extra_deps;
  setupHook = ./setup-hook.sh;
  calibrations = fetchFromGitHub {
    owner = "ECCE-EIC";
    repo = "calibrations";
    rev = "47ca5b0803a0b9c602174af9a4f003c31252cad6";
    hash = "sha256-MlNEtZjFyED5d6wGoOMVtM7E4DFPFAhat5WLwqdJb+A=";
  };
  postBuild = ''
    # remove any setup-hook if any came from paths
    rm "$out/nix-support/setup-hook" || true
    substituteAll "$setupHook" "$out/nix-support/setup-hook"
  '';
}
