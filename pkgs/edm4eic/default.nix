{ lib
, stdenv
, fetchFromGitHub
, cmake
, edm4hep
, podio
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "EDM4eic";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = "EDM4eic";
    rev = "v${version}";
    hash = "sha256-vwG+JOEmrD4s6wwGWlMT0VYBQVxNUWDiq1ceIVJ8aSw=";
  };

  nativeBuildInputs = [
    cmake
    python3
  ];
  propagatedBuildInputs = [
    edm4hep
  ];
  buildInputs = [
    podio
    root
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "Generic EIC Data Model for Simulations, Reconstruction, and Analysis";
    license = licenses.lgpl3Plus;
    homepage = "https://github.com/eic/EDM4eic";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
