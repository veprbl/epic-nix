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
  pname = "epic";
  version = "unstable-2022-08-06";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "d1336e5ff1b1f7adfe3defbd03fe7ac0cc1f1035";
    hash = "sha256-kkLZZF07lon/opAmUzgvhdYKe/L8BByNGBZNsVn9Wxc=";
  };

  postPatch = ''
    patchShebangs --host bin/make_detector_configuration

    substituteInPlace templates/epic.xml.jinja2 \
      --replace '"ip6/' '"''${BEAMLINE_PATH}/ip6/'
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

    # needed to avoid linking Geant libraries that may depend on Qt/OpenGL,
    # should be OFF by default anyway
    "-DUSE_DDG4=OFF"

    "-DEPIC_ECCE_LEGACY_COMPAT=OFF"
  ];

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "DD4hep Geometry Description of the EPIC Experiment";
    license = licenses.unfree; # no license
    homepage = "https://github.com/eic/epic";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
