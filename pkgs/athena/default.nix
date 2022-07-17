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
  pname = "athena";
  version = "unstable-2022-08-16";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "1008a184e989134a5a42db727a084d9e6a4a1cb6";
    hash = "sha256-Yinq4nLIA5Aj26lsXU9hXYolEbIATq6I49EM9cwJq8E=";
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
    description = "DD4hep Geometry Description of the ATHENA Experiment";
    license = licenses.unfree; # no license
    homepage = "https://github.com/eic/athena";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
