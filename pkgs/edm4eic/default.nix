{ lib
, stdenv
, edm4eic-src
, cmake
, edm4hep
, podio
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "EDM4eic";
  version = "7.0.0.${edm4eic-src.shortRev or "dirty"}";

  src = edm4eic-src;

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "find_package(podio 0.15 REQUIRED)" "find_package(podio REQUIRED)"
  '';

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
    "-DCMAKE_CXX_STANDARD=20"
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
