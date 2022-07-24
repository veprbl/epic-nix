{ lib
, stdenv
, fetchFromGitHub
, cmake
, acts
, dd4hep
, fmt
, python3
}:

stdenv.mkDerivation rec {
  pname = "ecce";
  version = "unstable-2022-08-24";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "1bf6192ea03f8a7e9b72de229527d908c63fb4be";
    hash = "sha256-X/4Z9ywJNipCexQV4s4RktcBHe++1U3/rCsBKmAPI6E=";
  };

  postPatch = ''
    patchShebangs --host bin/make_detector_configuration
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace templates/setup.sh.in \
      --replace LD_LIBRARY_PATH DYLD_LIBRARY_PATH
  '';

  nativeBuildInputs = [
    cmake
    python3
    python3.pkgs.jinja2
    python3.pkgs.pyyaml
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
    description = "DD4hep Geometry Description of the ECCE Experiment";
    license = licenses.unfree; # no license
    homepage = "https://github.com/eic/ecce";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
