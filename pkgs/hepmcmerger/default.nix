{ lib
, stdenv
, hepmcmerger-src
, cmake
, hepmc3
, root
}:

stdenv.mkDerivation rec {
  pname = "hepmcmerger";
  version = "1.0.5-${hepmcmerger-src.shortRev or "dirty"}";

  src = hepmcmerger-src;

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    hepmc3
    root
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_RPATH=${root}/lib" # needed for linking to root
  ];

  meta = with lib; {
    description = "A code used to to merge events from provided HEPMC files";
    license = licenses.unfree;
    homepage = "https://github.com/eic/HEPMC_Merger";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
