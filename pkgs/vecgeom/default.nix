{ lib
, stdenv
, fetchFromGitLab
, cmake
, geant4
, vc
, veccore
, xercesc
}:

stdenv.mkDerivation rec {
  pname = "vecgeom";
  version = "1.2.1";

  src = fetchFromGitLab {
    domain = "gitlab.cern.ch";
    owner = "VecGeom";
    repo = "VecGeom";
    rev = "v${version}";
    hash = "sha256-T5H4e66H64VOKqcz30tsezFME3x4lgrmbPAkOSfLJ8U=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    geant4
    vc
    veccore
    xercesc
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DVECGEOM_GDML=ON"
    "-DVECGEOM_GEANT4=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "The vectorized geometry library for particle-detector simulation";
    license = licenses.asl20;
    homepage = "https://gitlab.cern.ch/VecGeom/VecGeom";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
