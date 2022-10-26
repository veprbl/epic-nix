{ lib
, stdenv
, fetchFromGitHub
, cmake
, root
}:

stdenv.mkDerivation rec {
  pname = "irt";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-FaE0IFh0qjrPCbxDVzjbB/qyveZK4AdFbStvf0JCZ/8=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    root
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    description = "Indirect Ray Tracing library for EPIC Cherenkov detector reconstruction";
    license = licenses.unfree; # https://github.com/eic/irt/issues/18
    homepage = "https://github.com/eic/irt";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
