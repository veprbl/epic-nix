{ lib
, stdenv
, fetchurl
, cmake
, gsl
, root
}:

stdenv.mkDerivation rec {
  pname = "sartre";
  version = "1.39";

  src = fetchurl rec {
    name = "sartre-${version}-src.tgz";
    url = "https://sartre.hepforge.org/downloads/?f=${name}";
    hash = "sha256-gu13JDvqYbuTNfcFxLEy8LU9DeF8JriTifqc063O9E0=";
  };

  # required by recent ROOT
  postPatch = ''
    for file in gemini/CMakeLists.txt examples/CMakeLists.txt src/CMakeLists.txt; do
      substituteInPlace $file \
        --replace "set(CMAKE_CXX_STANDARD 11)" "set(CMAKE_CXX_STANDARD 17)"
    done
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    gsl
    root
  ];

  postInstall = ''
    mv "$out"/sartre/* "$out"/
    rmdir "$out"/sartre
    ln -s ./ "$out"/include/sartre
  '';

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "Event Generator for Diffractive Processes in ep and eA Collisions";
    license = licenses.gpl3Only;
    homepage = "https://sartre.hepforge.org/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
