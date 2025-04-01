{ lib
, stdenv
, fetchFromGitHub
, cmake
, edm4hep
, fixDarwinDylibNames
, gaudi
, podio
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "k4FWCore";
  version = "v01-01";

  src = fetchFromGitHub {
    owner = "key4hep";
    repo = pname;
    rev = "v01-01";
    hash = "sha256-wUJJpYEYRr/mJ5L5+YG+h5RuD0fyZhtwvtAyLSVlxDI=";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    cmake
  ] ++ lib.optionals stdenv.isDarwin [
    fixDarwinDylibNames
  ];
  buildInputs = [
    edm4hep
    gaudi
    podio
    python3
    root
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
    "-DGAUDI_INSTALL_PYTHONDIR=${python3.sitePackages}"
  ];

  meta = with lib; {
    description = "Core Components for the Gaudi-based Key4hep Framework";
    license = licenses.asl20;
    homepage = "https://github.com/key4hep/k4FWCore/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
