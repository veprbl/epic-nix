{ lib
, stdenv
, fetchFromGitHub
, cmake
, root
}:

stdenv.mkDerivation rec {
  pname = "GenFit";
  version = "02-00-00";

  src = fetchFromGitHub {
    owner = "GenFit";
    repo = pname;
    rev = version;
    hash = "sha256-PhjrmifYyyoy2JJt9FpRk7cz3o+cS5Bd+ezhmciQPzs=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    root
  ];

  cmakeFlags = [
  ];

  meta = with lib; {
    description = "An experiment-independent framework for track reconstruction in particle and nuclear physics";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/GenFit/GenFit";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
