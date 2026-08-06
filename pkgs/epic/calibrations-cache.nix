{ lib
, stdenv
, epic-src
, curl
, cacert
, python3
}:

stdenv.mkDerivation {
  pname = "epic-calibrations-cache";
  version = epic-src.shortRev or "dirty";

  src = epic-src;

  nativeBuildInputs = [
    curl
    cacert
    python3
  ];

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  buildPhase = ''
    mkdir -p calibrations-cache
    python3 ${./generate-calibrations-cache.py} \
      . \
      calibrations-cache
  '';

  installPhase = ''
    mkdir -p $out/share/epic
    cp -r calibrations-cache $out/share/epic/
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-MZaCmG9/s77cFjMbOw6WJtMHPhym/8A+yaz2U+8w6Xs=";

  meta = with lib; {
    description = "Pre-downloaded calibration files for the EPIC detector";
    license = licenses.free;
    platforms = platforms.all;
  };
}
