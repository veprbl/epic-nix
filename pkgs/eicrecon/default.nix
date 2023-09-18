{ lib
, stdenv
, eicrecon-src
, acts
, boost
, catch2_3
, cmake
, dd4hep
, edm4eic
, edm4hep
, eigen
, fastjet
, irt
, jana2
, nlohmann_json
, podio
, root
, spdlog
, xercesc
, makeWrapper
}:

let

  _fastjet = fastjet.overrideAttrs (prev: {
    configureFlags = prev.configureFlags ++ [
      "--enable-auto-ptr=no"
    ];
  });

in

stdenv.mkDerivation rec {
  pname = "EICrecon";
  version = "1.5.1.${eicrecon-src.shortRev or "dirty"}";

  src = eicrecon-src;

  postPatch = ''
    substituteInPlace cmake/jana_plugin.cmake \
      --replace '*.cc *.cpp *.c' '*.cc *.cpp'

    # workaround https://github.com/eic/EICrecon/issues/340
    substituteInPlace src/algorithms/tracking/CKFTracking.cc \
      --replace 'std::dynamic_pointer_cast' 'std::static_pointer_cast'
    substituteInPlace src/algorithms/tracking/IterativeVertexFinder.cc \
      --replace 'std::dynamic_pointer_cast' 'std::static_pointer_cast'
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
    _fastjet
    eigen
    irt
    jana2
    nlohmann_json
    podio
    root
    spdlog
    xercesc
  ];
  checkInputs = [
    catch2_3
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  NIX_CFLAGS_COMPILE = [ "-isystem ${eigen}/include/eigen3" ];
  LDFLAGS = lib.optionals stdenv.isDarwin [ "-Wl,-undefined,dynamic_lookup" ];

  doCheck = true;

  postInstall = ''
    wrapProgram "$out"/bin/eicrecon \
      --set-default JANA_PLUGIN_PATH "$out"/lib/EICrecon/plugins/
  '';

  meta = with lib; {
    description = "EIC Reconstruction - JANA based";
    license = with licenses; [ publicDomain lgpl3Plus ];
    homepage = "https://github.com/eic/EICrecon";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
