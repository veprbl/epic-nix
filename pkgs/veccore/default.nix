{ lib
, stdenv
, fetchFromGitHub
, cmake
, gtest
, vc
, xercesc
}:

stdenv.mkDerivation rec {
  pname = "veccore";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "root-project";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-FXUdn+BP1BccnYZEG+l6ZTaBYQaaxBH1w+zK7gblayM=";
  };

  # Workaround an issue with the Apple SDK
  postPatch = ''
    substituteInPlace include/VecCore/VecMath.h \
      --replace '#if defined(__APPLE__) && !defined(__NVCC__)' '#if 0' \
      --replace '#elif defined(_MSC_VER)' '#elif defined(_MSC_VER) || (defined(__APPLE__) && !defined(__NVCC__))'
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    vc
  ];
  checkInputs = [
    gtest
  ];

  cmakeFlags = [
    "-DVC=ON"
  ];

  doCheck = true;

  meta = with lib; {
    description = "C++ Library for Portable SIMD Vectorization";
    license = licenses.asl20;
    homepage = "https://github.com/root-project/veccore";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
