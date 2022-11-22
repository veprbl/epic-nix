{ lib
, stdenv
, fetchFromGitHub
, cmake
, dd4hep
, fmt_8
, opencascade-occt
, spdlog
, fontconfig
, libX11
, libGL
}:

stdenv.mkDerivation rec {
  pname = "npsim";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = "npsim";
    rev = "v${version}";
    hash = "sha256-jZMRiDtRiJlxNQJLmP4EMvAQSmVXw/gRfV0o9Equ+iQ=";
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
    fmt_8
    opencascade-occt
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
    description = "DD4hep-based simulation plugins, front-end, and related utilities";
    license = licenses.unfree; # https://github.com/eic/npsim/issues/1
    homepage = "https://github.com/eic/npsim";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
