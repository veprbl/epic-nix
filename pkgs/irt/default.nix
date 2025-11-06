{ lib
, stdenv
, irt-src
, cmake
, root
}:

stdenv.mkDerivation rec {
  pname = "irt";
  version = "1.0.6.${irt-src.shortRev or "dirty"}";

  src = irt-src;

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    root
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
    "-DIRT_ROOT_IO=OFF" # not needed for reconstruction
  ];

  meta = with lib; {
    description = "Indirect Ray Tracing library for EPIC Cherenkov detector reconstruction";
    license = licenses.lgpl3;
    homepage = "https://github.com/eic/irt";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
