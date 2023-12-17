{ lib
, stdenv
, fetchFromGitHub
, cmake
, root
}:

stdenv.mkDerivation rec {
  pname = "irt";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-f6oHbFEsCPi23h6lxO2dRQEDeXVTZX9/ueqQiwvze0g=";
  };

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
