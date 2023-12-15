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
  version = "11.0.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-OzVRVirSVQIn9xuQTo2Gk4nqI1geBiojUow2PDJvCrs=";
  };

  postPatch = ''
    substituteInPlace JugTrack/CMakeLists.txt \
      --replace 'libActsExamplesFramework.so' \
                '${"$"}{CMAKE_SHARED_LIBRARY_PREFIX}ActsExamplesFramework${"$"}{CMAKE_SHARED_LIBRARY_SUFFIX}'

    # https://eicweb.phy.anl.gov/EIC/juggler/-/merge_requests/528
    substituteInPlace external/algorithms/core/include/algorithms/detail/random.h \
      --replace "value_type" "result_type"
    substituteInPlace external/algorithms/core/include/algorithms/random.h \
      --replace "::value_type" "::result_type"
  '';

  nativeBuildInputs = [
    cmake
  ];
  propagatedBuildInputs = [
    gaudi
  ];
  buildInputs = [
    acts
    edm4eic
    edm4hep
    dd4hep
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

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "Concurrent Event Processor for EIC Experiments Based on the Gaudi Framework";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/juggler";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
