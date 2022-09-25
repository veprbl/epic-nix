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
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = "EDM4eic";
    rev = "v${version}";
    hash = "sha256-glCjveCAXUN5/YWNWMipLJ+9mVnRHMrUcjaHUQfTR1A=";
  };

  patches = [
    ./link_edm4hep.diff
  ];

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

  meta = with lib; {
    description = "Generic EIC Data Model for Simulations, Reconstruction, and Analysis";
    license = licenses.free; # FIXME https://github.com/eic/EDM4eic/issues/4
    homepage = "https://github.com/eic/EDM4eic";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
