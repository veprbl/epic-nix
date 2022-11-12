{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, acts
, cmake
, edm4eic
, edm4hep
, dd4hep
, gaudi
, genfit
, podio
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "juggler";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-PLqMPlwRkTiEnsRivA985r7O519RZd9LSZr/9/X5Dj8=";
  };

  # fix https://eicweb.phy.anl.gov/EIC/juggler/-/merge_requests/495
  postPatch = ''
    substituteInPlace external/algorithms/core/include/algorithms/detail/random.h \
      --replace 'constexpr value_type min() const' \
                'static constexpr value_type min()' \
      --replace 'constexpr value_type max() const' \
                'static constexpr value_type max()'
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    acts
    edm4eic
    edm4hep
    dd4hep
    gaudi
    genfit
    podio
    root
  ];

  ROOT_LIBRARY_PATH="${dd4hep}/lib";

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DGAUDI_INSTALL_PYTHONDIR=${python3.sitePackages}"
  ];

  NIX_CFLAGS_COMPILE = "-Wno-narrowing";

  meta = with lib; {
    description = "Concurrent Event Processor for EIC Experiments Based on the Gaudi Framework";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/juggler";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
