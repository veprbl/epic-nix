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
  version = "22.12.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = version;
    hash = "sha256-ViQm9VfITS0R4K8/NtZ8v+9t5okxDrMjbfobwDLYASw=";
  };

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
    description = "DD4hep Geometry Description of the EPIC Experiment";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/epic";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
