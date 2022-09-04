{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, acts
, cmake
, edm4eic
, edm4hep
, dd4hep
, gaudi
, genfit
, podio
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "juggler";
  version = "unstable-2022-08-23";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "f85f375aefd4b1ca5d02d791f6aeb8a9cf9f095d";
    hash = "sha256-3vgSl6tygbIafare4sf7/D0fvLMJ0xr5cxkKJ52jJbw=";
  };

  patches = [
    # support EDM4eic
    (fetchpatch {
      url = "https://eicweb.phy.anl.gov/EIC/juggler/-/commit/c71bd5203c1af79d064db50733623f41e14b3559.diff";
      hash = "sha256-9sRNvyUY8rEMLbYZuuYFdp7H3XPU8FibelYMmJ1uYhc=";
    })
  ];

  # https://eicweb.phy.anl.gov/EIC/juggler/-/merge_requests/430
  postPatch = ''
    substituteInPlace JugFast/src/components/InclusiveKinematicsTruth.cpp \
      --replace "#include <ranges>" ""
    substituteInPlace JugReco/src/components/InclusiveKinematicsElectron.cpp \
      --replace "#include <ranges>" ""
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    acts
    edm4eic
    edm4hep
    dd4hep
    gaudi
    genfit
    podio
    root
  ];

  ROOT_LIBRARY_PATH="${dd4hep}/lib";

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DGAUDI_INSTALL_PYTHONDIR=${python3.sitePackages}"
  ];

  NIX_CFLAGS_COMPILE = "-Wno-narrowing";

  meta = with lib; {
    description = "Concurrent Event Processor for EIC Experiments Based on the Gaudi Framework";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/juggler";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
