{ lib
, stdenv
, epic-src
, cmake
, dd4hep
, fmt
, python3
}:

stdenv.mkDerivation rec {
  pname = "epic";
  version = "25.11.1.${epic-src.shortRev or "dirty"}";

  src = epic-src;

  postPatch = ''
    patchShebangs --host bin/make_detector_configuration
  '';

  nativeBuildInputs = [
    cmake
    python3
    python3.pkgs.jinja2
    python3.pkgs.pyyaml
  ];
  buildInputs = [
    dd4hep
    fmt
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20" # match dd4hep
  ];

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "DD4hep Geometry Description of the EPIC Experiment";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/epic";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
