{ lib
, stdenv
, fetchFromGitHub
, cmake
, acts
, dd4hep
, fmt
}:

stdenv.mkDerivation rec {
  pname = "ip6";
  version = "unstable-2022-10-19";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "4b325c9c7f2aec14ab7a16e530f94e38d3303d34";
    hash = "sha256-HS5tR0YHtkZGICsavIHGYWBTN4pFV259rgceRJJdLdA=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    acts
    dd4hep
    fmt
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17" # match dd4hep

    # needed to avoid linking Geant libraries that may depend on Qt/OpenGL,
    # should be OFF by default anyway
    "-DUSE_DDG4=OFF"
  ];

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "DD4hep Geometry Description of the IP6 Beamline";
    license = licenses.unfree; # no license
    homepage = "https://github.com/eic/ip6";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
