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
  version = "unstable-2022-09-03";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "3651c6dc504bb03798c424cd4e064599d421e5ae";
    hash = "sha256-vtM427u9kBRrsjcNn7aU8uVAKXDZpg+mypjN0MWtCdc=";
  };

  postPatch = ''
    patchShebangs --host bin/make_detector_configuration

    substituteInPlace templates/epic.xml.jinja2 \
      --replace '"ip6/' '"''${BEAMLINE_PATH}/ip6/'
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
