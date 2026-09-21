{ lib
, stdenv
, epic-calibrations-cache-src
, curl
, cacert
, python3
}:

stdenv.mkDerivation {
  pname = "epic-calibrations-cache";
  version = epic-calibrations-cache-src.shortRev or "dirty";

  src = epic-calibrations-cache-src;

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
  outputHash = "sha256-eErXwu13ALzovqpYTEWnWyaBJwJVMTnpUGnGVm8u87w=";

  meta = with lib; {
    description = "Pre-downloaded calibration files for the EPIC detector";
    license = licenses.free;
    platforms = platforms.all;
  };
}
