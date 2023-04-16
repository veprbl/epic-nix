{ lib
, stdenv
, fetchFromGitHub
, cmake
, podio
, python3
, root
, xercesc
, zeromq
}:

stdenv.mkDerivation rec {
  pname = "jana2";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "JeffersonLab";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-DInxpCTBNmxk+tz0rQm2JULPHTiALSCX8iyeOANzZIw=";
  };

  patches = [
    # JParameterManager: specialize templates with more variants of the fundamental types
    ./jana2_pr218.patch

    # cmake: fix a conflict between USE_PODIO and USE_PYTHON
    ./jana2_pr219.patch
  ];

  postPatch = ''
    echo 'target_link_libraries(jana2_shared_lib podio::podio podio::podioRootIO)' >> src/libraries/JANA/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    podio
    python3
    python3.pkgs.pybind11
    root
    xercesc
    zeromq
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DUSE_PODIO=ON"
    "-DUSE_PYTHON=ON"
    "-DUSE_ROOT=ON"
    "-DUSE_XERCES=ON"
    "-DUSE_ZEROMQ=ON"
    "-DXercesC_DIR=${xercesc}"
  ];

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isDarwin [
    # error: aligned allocation function of type '...' is only available on macOS 10.14 or newer
    "-faligned-allocation"
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
