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
  version = "unstable-2022-08-16";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "79dd243399b06ad82f67bcbc04737772d13ba8a4";
    hash = "sha256-GiD/UBrB40L3m/cHAkmXq8XacFvU+8MXYim/kkiFXX8=";
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
  ];

  meta = with lib; {
    description = "DD4hep Geometry Description of the IP6 Beamline";
    license = licenses.unfree; # no license
    homepage = "https://github.com/eic/ip6";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
