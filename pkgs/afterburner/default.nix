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
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-33lHINAue+8Tr1vowdk5xF6LD+e7ooIyKjV7FBCO44Y=";
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
