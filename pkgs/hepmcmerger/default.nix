{ lib
, stdenv
, fetchFromGitHub
, cmake
, hepmc3
, root
}:

stdenv.mkDerivation rec {
  pname = "hepmcmerger";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "eic";
    repo = "HEPMC_Merger";
    rev = "v${version}";
    hash = "sha256-u+7H8I/t+ZbvP94KCYYsTS6aqokm6FXCfGSwfcbmuHQ=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    hepmc3
    root
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_RPATH=${root}/lib" # needed for linking to root
  ];

  meta = with lib; {
    description = "A code used to to merge events from provided HEPMC files";
    license = licenses.unfree;
    homepage = "https://github.com/eic/HEPMC_Merger";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
