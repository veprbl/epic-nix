{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "podio";
  version = "00-14-03";

  src = fetchFromGitHub {
    owner = "AIDASoft";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-beJXYggUQLfBtxWcmzj9oWVQasU8EzDoo+mxcTuXWkw=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    python3
    root
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    description = "A C++ library to support the creation and handling of data models in particle physics";
    longDescription = ''
      PODIO, or plain-old-data I/O, is a C++ library to support the creation
      and handling of data models in particle physics. It is based on the idea
      of employing plain-old-data (POD) data structures wherever possible,
      while avoiding deep-object hierarchies and virtual inheritance. This is
      to both improve runtime performance and simplify the implementation of
      persistency services.
    '';
    license = licenses.gpl3Only;
    homepage = "https://github.com/AIDASoft/podio";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
