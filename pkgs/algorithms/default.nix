{ lib
, stdenv
, algorithms-src
, cmake
, dd4hep
, edm4eic
, edm4hep
, fmt
, microsoft-gsl
}:

stdenv.mkDerivation rec {
  pname = "algorithms";
  version = "${algorithms-src.shortRev or "dirty"}";

  src = algorithms-src;

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-warn 'find_package(EDM4HEP 0.4.1 REQUIRED)' 'find_package(EDM4HEP 1.0 REQUIRED)'
    substituteInPlace truth/src/ParticlesWithTruthPID.cpp \
      --replace-warn 'rec_part.referencePoint()' 'rec_part.getReferencePoint()' \
      --replace-warn 'rec_assoc.setRecID(rec_part.getObjectID().index)' 'rec_assoc.setRec(rec_part)' \
      --replace-warn 'rec_assoc.setSimID(mc[best_match].getObjectID().index)' 'rec_assoc.setSim(mc[best_match])'
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    dd4hep
    edm4eic
    edm4hep
    fmt
    microsoft-gsl
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "Collection of Reconstruction Algorithms using DD4hep and EDM4hep";
    license = with licenses; [ lgpl3Plus ];
    homepage = "https://github.com/eic/algorithms";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
