{ lib
, stdenv
, fetchFromGitHub
, cmake
, hepmc3
, root
, zlib
}:

stdenv.mkDerivation rec {
  pname = "eic-smear";
  version = "1.1.13";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = version;
    hash = "sha256-Jk7Rh6bqjgxtdQZ7EK49gQ6hF70L1CtFTfrkUHD0H+4=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'target_link_libraries(eicsmear ' \
                     'target_link_libraries(eicsmear PUBLIC '
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    hepmc3
    root
    zlib
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "Fast simulation tool originally developed by the BNL EIC task force";
    license = licenses.unfree; # no license provided https://github.com/eic/eic-smear/issues/20
    homepage = "https://eic.github.io/software/eicsmear.html";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
