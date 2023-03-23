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
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "eic";
    repo = "EDM4eic";
    rev = "v${version}";
    hash = "sha256-dWcmOdMBlge928+Tsv63m0qEtEo5fbTRUbc4JJrXZP0=";
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
    license = licenses.free; # FIXME https://github.com/eic/EDM4eic/issues/4
    homepage = "https://github.com/eic/EDM4eic";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
