{ lib
, stdenv
, fetchFromGitHub
, acts
, cmake
, edm4hep
, eicd
, dd4hep
, gaudi
, genfit
, podio
, root
}:

stdenv.mkDerivation rec {
  pname = "juggler";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Ub1qrB5WCvbUf1bKbYoz9Lff5PhdcSxwp/Ts9DgwFOY=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    acts
    edm4hep
    eicd
    dd4hep
    gaudi
    genfit
    podio
    root
  ];

  ROOT_LIBRARY_PATH="${dd4hep}/lib";

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  NIX_CFLAGS_COMPILE = "-Wno-narrowing";

  meta = with lib; {
    broken = stdenv.isDarwin; # crashes in listcomponents during build time
    description = "Concurrent Event Processor for EIC Experiments Based on the Gaudi Framework";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/juggler";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
