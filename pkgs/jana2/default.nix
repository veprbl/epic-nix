{ lib
, stdenv
, jana2-src
, fetchpatch2
, cmake
, podio
, python3
, root
, xercesc
, cppzmq
, zeromq
}:

stdenv.mkDerivation rec {
  pname = "jana2";
  version = "2026.03.00.${jana2-src.shortRev or "dirty"}";

  src = jana2-src;

  postPatch = ''
    substituteInPlace src/libraries/JANA/CLI/JSignalHandler.cc \
      --replace-warn "ss << g_app->GetComponentSummary() << std::endl;" ""
    substituteInPlace src/libraries/JANA/JApplication.cc \
      --replace-warn "LOG_INFO(m_logger) << GetComponentSummary() << LOG_END;" ""

    # JANA2 v2026.03.00 removed the bundled FindZeroMQ.cmake. The upstream
    # ZeroMQConfig.cmake provided by zeromq defines the imported target `libzmq`
    # but only sets ZeroMQ_LIBRARY (singular), not ZeroMQ_LIBRARIES. The
    # janacontrol plugin still uses the plural variable, so the link line ends up
    # empty and janacontrol.so is built with unresolved zmq_* symbols. Link
    # directly against the `libzmq` target instead.
    substituteInPlace src/plugins/janacontrol/CMakeLists.txt \
      --replace-fail 'target_include_directories(janacontrol PUBLIC ''${ZeroMQ_INCLUDE_DIRS})' "" \
      --replace-fail 'target_link_libraries(janacontrol PUBLIC ''${ZeroMQ_LIBRARIES})' 'target_link_libraries(janacontrol PUBLIC libzmq)' \
      --replace-fail 'target_include_directories(janacontrol-tests PUBLIC ''${ZeroMQ_INCLUDE_DIRS})' "" \
      --replace-fail 'target_link_libraries(janacontrol-tests PUBLIC ''${ZeroMQ_LIBRARIES})' 'target_link_libraries(janacontrol-tests PUBLIC libzmq)'
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
  ];
  propagatedBuildInputs = [
    cppzmq
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

  # error: aligned allocation function of type '...' is only available on macOS 10.14 or newer
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-faligned-allocation";

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
