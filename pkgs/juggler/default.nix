{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, acts
, cmake
, edm4eic
, edm4hep
, eigen
, dd4hep
, gaudi
, genfit
, k4FWCore
, podio
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "juggler";
  version = "13.0.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-lg5C261mpls411IVtwFEBcNbOL9DhGFVppJUsBbWX4E=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/eic/juggler/commit/61cf5c5d67889c3c26eacc3d831e8608f6c3255e.diff";
      hash = "sha256-4M6A4rAvsDJegTqd+UJz89pQKFZCTGmVDJwjVHChRVI=";
    })
    (fetchpatch {
      url = "https://github.com/eic/juggler/commit/de7fc2656b1d6e0933a3500617f39f1e1da1f9d4.diff";
      hash = "sha256-Czq14bP1ivfgqrYduB8G5DhugzjGbarAmcvftgc7BIo=";
    })
    (fetchpatch {
      url = "https://github.com/eic/juggler/commit/8e6d75c21011af76a2492c7f4840b16833874245.diff";
      hash = "sha256-e7jQLdbhdxfDj2pnSP1Y4zdPbY2jqpOA47Fj66qra1A=";
    })
    (fetchpatch {
      url = "https://github.com/eic/juggler/commit/b903d32c7fe3813b57e65a528cfa871d69d582b6.diff";
      hash = "sha256-NbJWVaBmYhDITMAErh4hVuDcbWw0y6RTVpMiz0hswjY=";
    })
  ];

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
    eigen
    dd4hep
    genfit
    k4FWCore
    podio
    root
  ];

  ROOT_LIBRARY_PATH="${dd4hep}/lib";

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
    "-DGAUDI_INSTALL_PYTHONDIR=${python3.sitePackages}"
  ];

  NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" "-Wno-narrowing" ];

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "Concurrent Event Processor for EIC Experiments Based on the Gaudi Framework";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/juggler";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
