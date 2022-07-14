{ lib
, stdenv
, fetchFromGitLab
, fetchpatch
, boost
, cmake
, cppunit
, doxygen
, fmt
, gperftools
, jemalloc
, microsoft_gsl
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
  version = "36r5";

  src = fetchFromGitLab {
    domain = "gitlab.cern.ch";
    owner = "gaudi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-zSJLK6GysNM+xhPZP5K4hTrVSEYGUZjrvuojBfulUZ8=";
  };

  patches = [
    # fix for libc++
    (fetchpatch {
      url = "https://gitlab.cern.ch/gaudi/Gaudi/-/commit/d7aaac403909b52eb81ec06ff692dc758c47d8ae.diff";
      revert = true;
      includes = [ "GaudiPluginService/include/Gaudi/PluginServiceV2.h" ];
      hash = "sha256-o05iYMCr+RKbkY/DDE0B3U5kVuqYqd4MQeOyVu01JJo=";
    })
  ];

  nativeBuildInputs = [
    cmake
    python3.pkgs.six
  ];
  buildInputs = [
    _boost
    cppunit
    doxygen
    fmt
    gperftools
    jemalloc
    microsoft_gsl
    python3
    range-v3
    root
    tbb
    xercesc
    zlib
  ] ++ lib.optionals stdenv.isDarwin [ Foundation ];

  postPatch = ''
    patchShebangs --build GaudiKernel/scripts/

    sed -i GaudiHive/src/PRGraph/PrecedenceRulesGraph.cpp \
      -e '1i#include <boost/filesystem/fstream.hpp>'
  '';

  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=OFF" # until this lands https://github.com/NixOS/nixpkgs/pull/108496
    "-DGAUDI_CXX_STANDARD=17"
    "-DGAUDI_USE_AIDA=FALSE"
    "-DGAUDI_USE_CLHEP=FALSE"
    "-DGAUDI_USE_HEPPDT=FALSE"
    "-DGAUDI_USE_UNWIND=FALSE"
  ];

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
