{ lib
, stdenv
, fetchFromGitHub
, hepmc
, cmake
, podio
, python3
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

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/EDM4HEPBuild.cmake \
      --replace 'set(CMAKE_INSTALL_NAME_DIR "@rpath")' "" \
      --replace 'set(CMAKE_INSTALL_RPATH "@loader_path/../lib")' ""
  '';

  nativeBuildInputs = [
    cmake
    python3
  ];
  propagatedBuildInputs = [
    podio
  ];
  buildInputs = [
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
