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
  version = "2.0.0";

  src = fetchFromGitLab {
    domain = "gitlab.cern.ch";
    owner = "VecGeom";
    repo = "VecGeom";
    rev = "refs/tags/v${version}";
    hash = "sha256-ItYYP5dzk0Vh4RuXnGPr36WIkQndBAOe+La11vTxbx0=";
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

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=missing-template-arg-list-after-template-kw";

  # TestPolyhedra and TestSphere failing on aarch64-linux and aarch64-darwin
  doCheck = !stdenv.hostPlatform.isAarch64;

  meta = with lib; {
    description = "The vectorized geometry library for particle-detector simulation";
    license = licenses.asl20;
    homepage = "https://gitlab.cern.ch/VecGeom/VecGeom";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
