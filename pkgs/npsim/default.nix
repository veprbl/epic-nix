{ lib
, stdenv
, fetchFromGitHub
, cmake
, dd4hep
, geant4
, opencascade-occt
, spdlog
, tcl
, tk
, fontconfig
, libX11
, libGL
}:

stdenv.mkDerivation rec {
  pname = "npsim";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "eic";
    repo = "npsim";
    rev = "v${version}";
    hash = "sha256-wTyDlIG/YxySRV55BakvL0sgajEk8IdLZTt+TtSs+vU=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "FetchContent_MakeAvailable(Catch2)" ""
  '';

  nativeBuildInputs = [
    cmake
  ] ++ geant4.propagatedNativeBuildInputs; # provides Qt
  buildInputs = [
    dd4hep
    opencascade-occt
    spdlog
    tcl # needed for opencascade-occt on linux
    tk # needed for opencascade-occt on linux
  ] ++ lib.optional stdenv.isLinux [
    (lib.getLib fontconfig)
    libX11
    libGL
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20" # match dd4hep
  ];

  # not every executable is a binary - process them manually
  dontWrapQtApps = true;
  postFixup = lib.optionalString geant4.enableQt ''
    for file in $(find "$out"/bin -type f -executable); do
      wrapQtApp "$file"
    done
  '';

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "DD4hep-based simulation plugins, front-end, and related utilities";
    license = licenses.unfree; # https://github.com/eic/npsim/issues/1
    homepage = "https://github.com/eic/npsim";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
