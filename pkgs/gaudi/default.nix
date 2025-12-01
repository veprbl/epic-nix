{ lib
, stdenv
, fetchFromGitLab
, fetchurl
, fetchpatch
, aida
, bash
, boost
, cmake
, clhep
, cppunit
, doxygen
, fmt
, gperftools
, jemalloc
, libuuid
, makeWrapper
, microsoft_gsl
, nlohmann_json
, pkg-config
, python3
, range-v3
, root
, tbb
, xercesc
, zlib
}:

let

  _boost = boost.override { python = python3; enablePython = true; };

in

stdenv.mkDerivation rec {
  pname = "Gaudi";
  version = "39r4";

  src = fetchFromGitLab {
    domain = "gitlab.cern.ch";
    owner = "gaudi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-rCYeEt1wvzyrI+95lVgi1XQlhJODP5VxbomHVAqPchA=";
  };

  findtbb_cmake = fetchurl {
    url = "https://gitlab.cern.ch/gaudi/Gaudi/-/raw/a8e9986cb6f0eb3d8e4b44589d53b4531a5c2041/cmake/modules/FindTBB.cmake";
    hash = "sha256-iiUonNq8GjxGfbPDXwTqo2I7Gm8NIKIPy1ezRloVEqk=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    python3.pkgs.six
  ];

  propagatedNativeBuildInputs = [
    pkg-config
  ];

  propagatedBuildInputs = [
    aida
    _boost
    fmt
    gperftools
    jemalloc
    libuuid
    microsoft_gsl
    nlohmann_json
    range-v3
    tbb
    xercesc
    zlib
  ];

  buildInputs = [
    _boost
    clhep
    cppunit
    doxygen
    python3
    root
  ];

  postPatch = ''
    patchShebangs --build GaudiKernel/scripts/
    substituteInPlace cmake/GaudiToolbox.cmake \
      --replace '/bin/sh' '${bash}/bin/sh'
    substituteInPlace cmake/GaudiDependencies.cmake \
      --replace-fail 'find_package(TBB 2019.0.11007.2 CONFIG ' 'find_package(TBB 2019.0.11007.2 '
    cp "$findtbb_cmake" cmake/modules/FindTBB.cmake
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace GaudiKernel/include/GaudiKernel/VectorMap.h \
      --replace "typename ALLOCATOR::size_type" std::size_t \
      --replace "typename ALLOCATOR::difference_type" std::ptrdiff_t
    substituteInPlace GaudiKernel/src/Util/genconf.cpp \
      --replace "libNativeName( lib ) != info.library" "false"
  '';

  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=OFF" # until this lands https://github.com/NixOS/nixpkgs/pull/108496
    "-DGAUDI_CXX_STANDARD=20"
    "-DGAUDI_USE_AIDA=TRUE"
    "-DGAUDI_USE_CLHEP=TRUE"
    "-DGAUDI_USE_HEPPDT=FALSE"
    "-DGAUDI_USE_UNWIND=FALSE"
    "-DGAUDI_INSTALL_PYTHONDIR=${python3.sitePackages}"
  ];

  postInstall = ''
    patchShebangs --host "$out"/bin
    wrapProgram "$out"/bin/gaudirun.py \
      --prefix LD_LIBRARY_PATH : "$out"/lib \
      ${lib.optionalString stdenv.isDarwin ''--prefix DYLD_LIBRARY_PATH : "$out"/lib''} \
      --prefix PYTHONPATH : "$PYTHONPATH:$out/${python3.sitePackages}"
  '';

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    broken = stdenv.hostPlatform.isDarwin;
    description = "A reconstruction framework";
    longDescription = ''
      The Gaudi project is an open project for providing the necessary
      interfaces and services for building HEP experiment frameworks in the
      domain of event data processing applications. The Gaudi framework is
      experiment independent.
    '';
    license = licenses.asl20;
    homepage = "https://gitlab.cern.ch/gaudi/Gaudi";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
