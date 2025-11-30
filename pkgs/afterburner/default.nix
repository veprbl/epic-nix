{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, clhep
, gsl
, hepmc3
, yaml-cpp
, root
}:

stdenv.mkDerivation rec {
  pname = "afterburner";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-H5JzjgSRO4O+32BzP0w+bomTRmuuAZgwUHVesZ0Lbrs=";
  };

  patches = [
    ./macos_fixes.patch

    # catch2 is broken with recent glibc
    (fetchpatch {
      url = "https://github.com/eic/afterburner/commit/44b80f05ec8993c559d3e35b6526ebac46a0f8ff.diff";
      hash = "sha256-EugILCMF8sxQszlfQZXwLNQPq9ii+AJHlqeoenbShPw=";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    clhep
    gsl
    hepmc3
    yaml-cpp
    root
  ];

  cmakeDir = "../cpp";

  meta = with lib; {
    description = "Monte Carlo Afterburner for Crossing Angle and Beam Effects";
    license = licenses.unfree; # no license provided https://github.com/eic/afterburner/issues/1
    homepage = "https://github.com/eic/afterburner";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
