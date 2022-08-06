{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, hepmc3
, root
, zlib
}:

stdenv.mkDerivation rec {
  pname = "eic-smear";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = version;
    hash = "sha256-K/UzH2Ti/GtGm8X5sLzCMx8AjEZluTbGt+g/zsL4xrE=";
  };

  patches = [
    # fix build on clang
    (fetchpatch {
      url = "https://github.com/eic/eic-smear/pull/21/commits/9854378900602dd0dda9071c557abe7b0873ef01.diff";
      hash = "sha256-Goz+YjgqeZF0OhbGivsFvynkoiymkn4o5dXnOLuBszg=";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    hepmc3
    root
    zlib
  ];

  meta = with lib; {
    description = "Fast simulation tool originally developed by the BNL EIC task force";
    license = licenses.unfree; # no license provided https://github.com/eic/eic-smear/issues/20
    homepage = "https://eic.github.io/software/eicsmear.html";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
