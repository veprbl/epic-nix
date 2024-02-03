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
  version = "2.1.2.${jana2-src.shortRev or "dirty"}";

  src = jana2-src;

  patches = [
    # PODIO compatibility https://github.com/JeffersonLab/JANA2/pull/269
    (fetchpatch {
      url = "https://github.com/JeffersonLab/JANA2/commit/6bbab9929bd2e03dec4b43af19453d6163b5f9c6.diff";
      hash = "sha256-CTo6+2JUDeiUeECUJPtvn+sdr6mnY6jKZYRa0SmbA5I=";
    })
    (fetchpatch {
      url = "https://github.com/JeffersonLab/JANA2/commit/3c12d58f5489448283dbc6a88397d1cea20b4a2e.diff";
      hash = "sha256-5N4D+3taDs6N5aCiT46M+Jw9FPlU0VC14hRsTYFK1VA=";
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
    "-DCMAKE_CXX_STANDARD=20"
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
