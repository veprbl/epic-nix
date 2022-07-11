{ lib
, stdenv
, fetchFromGitHub
, hepmc
, cmake
, podio
, root
}:

stdenv.mkDerivation rec {
  pname = "EDM4hep";
  version = "00-05";

  src = fetchFromGitHub {
    owner = "key4hep";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ssrVoPXWF24O0D0m2LTz//UOE5o3X/KDcqSelYRJaKg=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    podio
    root
  ];
  checkInputs = [
    hepmc
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    description = "Generic event data model for HEP collider experiments";
    license = licenses.asl20;
    homepage = "https://cern.ch/edm4hep";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
