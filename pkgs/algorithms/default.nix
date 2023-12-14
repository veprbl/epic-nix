{ lib
, stdenv
, algorithms-src
, cmake
, dd4hep
, edm4eic
, edm4hep
, fmt
, microsoft_gsl
}:

stdenv.mkDerivation rec {
  pname = "algorithms";
  version = "${algorithms-src.shortRev or "dirty"}";

  src = algorithms-src;

  # https://github.com/eic/algorithms/pull/10
  postPatch = ''
    substituteInPlace core/include/algorithms/detail/random.h \
      --replace "value_type" "result_type"
    substituteInPlace core/include/algorithms/random.h \
      --replace "::value_type" "::result_type"
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    dd4hep
    edm4eic
    edm4hep
    fmt
    microsoft_gsl
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    description = "Collection of Reconstruction Algorithms using DD4hep and EDM4hep";
    license = with licenses; [ lgpl3Plus ];
    homepage = "https://github.com/eic/algorithms";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
