{ lib
, stdenv
, fetchFromGitHub
, acts
, boost
, cmake
, dd4hep
, edm4eic
, edm4hep
, eigen
, irt
, fmt_8
, jana2
, nlohmann_json
, podio
, root
, spdlog
, xercesc
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "EICrecon";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/AHv091Bi5wmZ75nuL2l0q+8iD+30Mjf0qfkBVGVTmw=";
  };

  postPatch = ''
    substituteInPlace cmake/jana_plugin.cmake \
      --replace '*.cc *.cpp *.c' '*.cc *.cpp'

    # workaround https://github.com/eic/EICrecon/issues/340
    substituteInPlace src/algorithms/tracking/CKFTracking.cc \
      --replace 'std::dynamic_pointer_cast' 'std::static_pointer_cast'

    # workaround https://github.com/eic/EICrecon/issues/483
    echo 'target_link_libraries(''${PLUGIN_NAME}_plugin richgeo_plugin)' src/services/geometry/rich/CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];
  buildInputs = [
    acts
    boost
    dd4hep
    edm4eic
    edm4hep
    eigen
    fmt_8
    irt
    jana2
    nlohmann_json
    podio
    root
    spdlog
    xercesc
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
  LDFLAGS = lib.optionals stdenv.isDarwin [ "-Wl,-undefined,dynamic_lookup" ];

  postInstall = ''
    wrapProgram "$out"/bin/eicrecon \
      --set-default JANA_PLUGIN_PATH "$out"/lib/EICrecon/plugins/
  '';

  meta = with lib; {
    description = "EIC Reconstruction - JANA based";
    license = licenses.unfree; # https://github.com/eic/EICrecon/issues/2
    homepage = "https://github.com/eic/EICrecon";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
