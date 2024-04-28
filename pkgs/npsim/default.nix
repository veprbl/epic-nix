{ lib
, stdenv
, fetchFromGitHub
, cmake
, dd4hep
, geant4
, opencascade-occt
, spdlog
, fontconfig
, libX11
, libGL
}:

stdenv.mkDerivation rec {
  pname = "npsim";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "eic";
    repo = "npsim";
    rev = "v${version}";
    hash = "sha256-Fd3h3stZydZhLkTClPvT3yimL0tioAPqvs8bzfrnTUY=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "FetchContent_MakeAvailable(Catch2)" ""
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    dd4hep
    opencascade-occt
    spdlog
  ] ++ lib.optional stdenv.isLinux [
    (lib.getLib fontconfig)
    libX11
    libGL
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20" # match dd4hep
  ];

  meta = with lib; {
    description = "DD4hep-based simulation plugins, front-end, and related utilities";
    license = licenses.unfree; # https://github.com/eic/npsim/issues/1
    homepage = "https://github.com/eic/npsim";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
