{ lib
, stdenv
, irt2-src
, cmake
, root
}:

stdenv.mkDerivation rec {
  pname = "irt2";
  version = "2.1.3.${irt2-src.shortRev or "dirty"}";

  src = irt2-src;

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    root
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
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
