{ lib
, stdenv
, fetchFromGitHub
, cmake
, edm4hep
, podio
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "eicd";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = "eicd";
    rev = "v${version}";
    hash = "sha256-WvuFpleSBj5UgEOARF30Qpf++oggtxxFNTtIAqegwEE=";
  };

  nativeBuildInputs = [
    cmake
    python3
  ];
  buildInputs = [
    edm4hep
    podio
    root
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    description = "Generic EIC Data Model for Simulations, Reconstruction, and Analysis";
    license = licenses.free; # FIXME https://eicweb.phy.anl.gov/EIC/eicd/-/issues/28
    homepage = "http://dd4hep.cern.ch/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
