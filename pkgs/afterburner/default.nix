{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, clhep
, gsl
, hepmc3
, yaml-cpp
, root
}:

stdenv.mkDerivation rec {
  pname = "afterburner";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-TEvC+mjC9Wun1Ol7TJhl2FNm9iToBepNntpQxQbBvuY=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    clhep
    gsl
    hepmc3
    yaml-cpp
    root
  ];

  cmakeDir = "../cpp";

  meta = with lib; {
    description = "Monte Carlo Afterburner for Crossing Angle and Beam Effects";
    license = licenses.unfree; # no license provided https://github.com/eic/afterburner/issues/1
    homepage = "https://github.com/eic/afterburner";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
