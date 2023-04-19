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
  version = "9.4.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-U4080BWg7IMj1CQP0+YRCemdP4crri/sPbUqCTRX+qg=";
  };

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
