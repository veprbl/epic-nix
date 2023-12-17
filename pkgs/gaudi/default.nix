{ lib
, stdenv
, fetchFromGitLab
, fetchFromGitHub
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
, pkg-config
, python3
, range-v3
, root
, tbb
, xercesc
, zlib
, Foundation
}:

let

  _boost = boost.override { python = python3; enablePython = true; };

in

stdenv.mkDerivation rec {
  pname = "Gaudi";
  version = "36r16";

  src = fetchFromGitLab {
    domain = "gitlab.cern.ch";
    owner = "gaudi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-qMIZESS9hDdgVnZ8qR/KhUQVO8xBCAmqq/XoQc5fT+w=";
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
    range-v3
    tbb
    xercesc
  ] ++ lib.optionals stdenv.isDarwin [ Foundation ];
  buildInputs = [
    _boost
    clhep
    cppunit
    doxygen
    python3
    root
    zlib
  ];

  postPatch = ''
    patchShebangs --build GaudiKernel/scripts/
    substituteInPlace cmake/GaudiToolbox.cmake \
      --replace '/bin/sh' '${bash}/bin/sh'
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace GaudiKernel/include/GaudiKernel/VectorMap.h \
      --replace "typename ALLOCATOR::size_type" std::size_t \
      --replace "typename ALLOCATOR::difference_type" std::ptrdiff_t
    substituteInPlace GaudiKernel/src/Util/genconf.cpp \
      --replace "libNativeName( lib ) != info.library" "false"
  '';

  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=OFF" # until this lands https://github.com/NixOS/nixpkgs/pull/108496
    "-DGAUDI_CXX_STANDARD=17"
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
