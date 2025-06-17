{ lib
, stdenv
, eicrecon-src
, acts
, algorithms
, boost
, catch2_3
, cmake
, dd4hep
, edm4eic
, edm4hep
, eigen
, fastjet
, fastjet-contrib
, irt
, jana2
, microsoft_gsl
, nlohmann_json
, onnxruntime
, podio
, root
, spdlog
, xercesc
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "EICrecon";
  version = "1.26.0-${eicrecon-src.shortRev or "dirty"}";

  src = eicrecon-src;

  postPatch = ''
    echo 'plugin_add_algorithms(''${PLUGIN_NAME})' >> src/algorithms/digi/CMakeLists.txt
    echo '#include <JANA/JApplication.h>' >> src/services/geometry/dd4hep/DD4hep_service.h
    substituteInPlace cmake/jana_plugin.cmake \
      --replace 'target_link_libraries(''${_name}_plugin ''${_name}_library>)' 'target_link_libraries(''${_name}_plugin ''${_name}_library)' \
      --replace '*.cc *.cpp *.c' '*.cc *.cpp'

    # workaround https://github.com/eic/EICrecon/issues/340
    substituteInPlace src/algorithms/tracking/CKFTracking.cc \
      --replace 'std::dynamic_pointer_cast' 'std::static_pointer_cast'
    substituteInPlace src/algorithms/tracking/IterativeVertexFinder.cc \
      --replace 'std::dynamic_pointer_cast' 'std::static_pointer_cast'
  '' + lib.optionalString stdenv.isDarwin ''
    # loading plugins several times does not work on macOS
    : > src/tests/omnifactory_test/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];
  buildInputs = [
    acts
    algorithms
    boost
    dd4hep
    edm4eic
    edm4hep
    fastjet
    fastjet-contrib
    eigen
    irt
    jana2
    microsoft_gsl
    nlohmann_json
    onnxruntime
    podio
    root
    spdlog
    xercesc
  ];
  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
  ];

  env.NIX_CFLAGS_COMPILE = "-isystem ${eigen}/include/eigen3";
  env.LDFLAGS = lib.optionalString stdenv.isDarwin "-Wl,-undefined,dynamic_lookup";

  # For testing
  env.Catch2_DIR = "${catch2_3}/lib/cmake/Catch2";
  env.JANA_PLUGIN_PATH = "${placeholder "out"}/lib/EICrecon/plugins:${jana2}/plugins";

  checkInputs = [
    catch2_3
  ];

  doInstallCheck = true;
  installCheckTarget = "test";

  postInstall = ''
    wrapProgram "$out"/bin/eicrecon \
      --set-default JANA_PLUGIN_PATH "$out"/lib/EICrecon/plugins:"${jana2}"/plugins
  '';

  meta = with lib; {
    description = "EIC Reconstruction - JANA based";
    license = with licenses; [ publicDomain lgpl3Plus ];
    homepage = "https://github.com/eic/EICrecon";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
