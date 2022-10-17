{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, acts
, boost
, cmake
, dd4hep
, edm4eic
, edm4hep
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
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-/L+7eb9YYZjtK9aypy+/AYCcWrl93n41NplfP2XaYGI=";
  };

  patches = [
    # https://github.com/eic/EICrecon/pull/284
    (fetchpatch {
      url = "https://github.com/eic/EICrecon/commit/b18b91924922c5015b151fd308086629f3da3641.diff";
      hash = "sha256-Mtmhr2n6PnW/HvsEma14d4teWRHiV8V7IZvGjKgIexk=";
    })
  ];

  postPatch = ''
    substituteInPlace src/services/io/podio/JEventSourcePODIOsimple.cc \
      --replace '_exit(-1);' 'std::terminate();';
    substituteInPlace cmake/jana_plugin.cmake \
      --replace '*.cc *.cpp *.c' '*.cc *.cpp'
    substituteInPlace src/utilities/dump_flags/DumpFlags_processor.h \
      --replace 'std::ptr_fun<int, int>(' 'static_cast<int (*)(int)>(&'
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
