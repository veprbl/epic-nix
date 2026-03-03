{ lib
, stdenv
, fetchFromGitHub
, cmake
, zlib
, fixDarwinDylibNames
}:

stdenv.mkDerivation rec {
  pname = "sio";
  version = "unstable-2026-02-18";

  src = fetchFromGitHub {
    owner = "iLCSoft";
    repo = "SIO";
    rev = "45df4cf4cc4618e22cdd3f8d90a1baabb1a6eacf";
    hash = "sha256-ByEbn+96EXA/ldqwLGLMYLcPwtKTMl18HQZ36tsuX8A=";
  };

  nativeBuildInputs = [
    cmake
  ] ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;
  propagatedBuildInputs = [
    zlib
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
    "-DSIO_BUILTIN_ZLIB=OFF"
  ];

  meta = with lib; {
    description = "SIO is a persistency solution for reading and writing binary data in SIO structures called record and block.";
    license = licenses.bsd3;
    homepage = "https://github.com/iLCSoft/SIO";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
