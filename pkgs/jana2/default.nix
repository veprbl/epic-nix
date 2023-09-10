{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, podio
, python3
, root
, xercesc
, zeromq
}:

stdenv.mkDerivation rec {
  pname = "jana2";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "JeffersonLab";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-P9SZxtsqhwhYJ9X00v5EDToKKJsCvfLgWICB2bjJDD8=";
  };

  patches = [
    # https://github.com/JeffersonLab/JANA2/pull/239
    (fetchpatch {
      url = "https://github.com/JeffersonLab/JANA2/commit/36dcd4928670418ac6b90c2a0b835586eca6a18e.diff";
      hash = "sha256-Hausq0YXwDXI7peLbTY5dkKMC0v92hOiZ8BdmDvHcUc=";
    })
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
