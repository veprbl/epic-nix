{ lib
, stdenv
, fetchFromGitLab
, acts-dd4hep
, cmake
, dd4hep
, fmt_8
, opencascade-occt
, podio
, python3
, spdlog
, which
, fontconfig
, libX11
, libGL
}:

stdenv.mkDerivation rec {
  pname = "npdet";
  version = "unstable-2022-10-03";

  src = fetchFromGitLab {
    domain = "eicweb.phy.anl.gov";
    owner = "EIC";
    repo = "NPDet";
    rev = "16d12a36bd8f8e4a00b747ea6aa88ba366d12cd4";
    hash = "sha256-pEn3oi8+rrWeZR0Fs8sIlYUvfYNiKD9T8b7xrSVPkbE=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "FetchContent_MakeAvailable(Catch2)" ""
  '';

  nativeBuildInputs = [
    cmake
    which
  ];
  buildInputs = [
    acts-dd4hep
    dd4hep
    fmt_8
    opencascade-occt
    podio
    python3
    spdlog
  ] ++ lib.optional stdenv.isLinux [
    (lib.getLib fontconfig)
    libX11
    libGL
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17" # match dd4hep
  ];

  meta = with lib; {
    description = "Nuclear Physics Detector library";
    license = licenses.unfree; # https://eicweb.phy.anl.gov/EIC/NPDet/-/issues/87
    homepage = "https://eicweb.phy.anl.gov/EIC/NPDet";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
