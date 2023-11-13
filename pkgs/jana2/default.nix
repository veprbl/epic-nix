{ lib
, stdenv
, jana2-src
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
  version = "2.1.1.${jana2-src.shortRev or "dirty"}";

  src = jana2-src;

  patches = [
    # https://github.com/JeffersonLab/JANA2/pull/237
    (fetchpatch {
      url = "https://github.com/JeffersonLab/JANA2/pull/237/commits/7f5b0d4b419964c916e365749d87b8d62c2c73af.diff";
      hash = "sha256-oEmiQgKRumCoZAgOBmsPSDp7jzqQQV0wNiAxsJcLTvA=";
    })

    # https://github.com/JeffersonLab/JANA2/pull/239
    (fetchpatch {
      url = "https://github.com/JeffersonLab/JANA2/commit/36dcd4928670418ac6b90c2a0b835586eca6a18e.diff";
      hash = "sha256-Hausq0YXwDXI7peLbTY5dkKMC0v92hOiZ8BdmDvHcUc=";
    })

    # https://github.com/eic/EICrecon/issues/949
    (fetchpatch {
      url = "https://github.com/JeffersonLab/JANA2/commit/fad0866d147913759b50789573066b40eb0abc16.diff";
      hash = "sha256-Fuf70sCDl7FKnlwKWfHC2LGZMNJ9IK5TV8a5ENUfO8s=";
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
