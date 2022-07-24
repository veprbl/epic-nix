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
  version = "unstable-2022-08-24";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "7d8d142cd701f6fc88f62b92fb9684c8b999ef5a";
    hash = "sha256-xfB/MKntQXoDWXi9NkqQ7GTrU42AY98vQHLcu6fo/Lc=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace templates/setup.sh.in \
      --replace LD_LIBRARY_PATH DYLD_LIBRARY_PATH
  '';

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
