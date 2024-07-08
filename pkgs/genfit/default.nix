{ lib
, stdenv
, fetchFromGitHub
, cmake
, rave
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

  postPatch = ''
    substituteInPlace cmake/FindROOT.cmake \
      --replace 'MATH(EXPR ROOT_found_version' 'set(ROOT_found_version "${builtins.replaceStrings ["."] [""] root.version}") #' \
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    rave
    root
  ];

  RAVEPATH=rave;

  meta = with lib; {
    description = "An experiment-independent framework for track reconstruction in particle and nuclear physics";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/GenFit/GenFit";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
