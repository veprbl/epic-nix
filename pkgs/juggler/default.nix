{ lib
, stdenv
, juggler-src
, acts
, algorithms
, cmake
, edm4eic
, edm4hep
, eigen
, dd4hep
, gaudi
, k4FWCore
, podio
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "juggler";
  version = "15.0.3-${juggler-src.shortRev or "dirty"}";

  src = juggler-src;

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "find_package(podio 0.16.3 REQUIRED)" "find_package(podio REQUIRED)"

    # https://eicweb.phy.anl.gov/EIC/juggler/-/merge_requests/563
    sed -i JugReco/src/components/CalorimeterIslandCluster.cpp -e '1i#include <fmt/ranges.h>'
    sed -i JugReco/src/components/ImagingPixelDataCombiner.cpp -e '1i#include <fmt/ranges.h>'
  '';

  nativeBuildInputs = [
    cmake
  ];
  propagatedBuildInputs = [
    gaudi
  ];
  buildInputs = [
    acts
    algorithms
    edm4eic
    edm4hep
    eigen
    dd4hep
    k4FWCore
    podio
    root
  ];


  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
    "-DGAUDI_INSTALL_PYTHONDIR=${python3.sitePackages}"
  ];

  env.ROOT_LIBRARY_PATH = "${dd4hep}/lib";
  env.NIX_CFLAGS_COMPILE = "-isystem ${eigen}/include/eigen3 -Wno-narrowing";

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    inherit (gaudi.meta) broken;
    description = "Concurrent Event Processor for EIC Experiments Based on the Gaudi Framework";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/juggler";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
