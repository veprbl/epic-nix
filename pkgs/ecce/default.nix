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
  version = "unstable-2022-08-16";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "21f4aeb6eea21b6bdd59c0447bb1fe6fcd7f6728";
    hash = "sha256-4w2YoZcScf+NBzZ0s2jTlE5Yb5uOiXj8HXXtay0pH+o=";
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
  ];

  meta = with lib; {
    description = "DD4hep Geometry Description of the ECCE Experiment";
    license = licenses.unfree; # no license
    homepage = "https://github.com/eic/ecce";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
