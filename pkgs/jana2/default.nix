{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, root
, xercesc
, zeromq
}:

stdenv.mkDerivation rec {
  pname = "jana2";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "JeffersonLab";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-5CkxCsOCgx+La6j+sssf3HNejadEuTUvsyAnf/PbJXc=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    python3
    root
    xercesc
    zeromq
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DUSE_ROOT=ON"
    "-DUSE_ZEROMQ=ON"
    "-DUSE_XERCES=ON"
    "-DUSE_PYTHON=ON"
    "-DXercesC_DIR=${xercesc}"
  ];

  meta = with lib; {
    description = "Multi-threaded HENP Event Reconstruction";
    longDescription = ''
      JANA is a C++ framework for multi-threaded HENP (High Energy and Nuclear
      Physics) event reconstruction. It is very efficient at multi-threading
      with a design that makes it easy for less experienced programmers to
      contribute pieces to the larger reconstruction project. The same JANA
      program can be used to easily do partial or full reconstruction, fully
      maximizing the available cores for the current job.
    '';
    license = licenses.bsd3;
    homepage = "https://jeffersonlab.github.io/JANA2/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
