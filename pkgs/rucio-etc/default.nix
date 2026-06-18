{ lib
, stdenv
, fetchurl
, eic-rucio-policy-package
, rucio
}:

stdenv.mkDerivation {
  pname = "rucio-etc";
  version = "unstable";

  src = fetchurl {
    url = "https://github.com/eic/containers/raw/c438dbc9df922ce2a2d2b3e89faf0148acdea660/containers/eic/Dockerfile";
    hash = "sha256-L7D1HRiDeOS8qPATWaFs25sDfAYH0a3ts4UH7AHEUuA=";
  };

  dontUnpack = true;

  propagatedBuildInputs = [
    eic-rucio-policy-package
    rucio
  ];

  installPhase = ''
    runHook preInstall

    # Extract rucio.cfg content from the Dockerfile heredoc
    sed -n '/^COPY <<EOF \/opt\/rucio\/etc\/rucio.cfg/,/^EOF/{/^COPY/d;/^EOF/d;p}' "$src" > rucio.cfg

    mkdir -p $out/etc
    cp rucio.cfg $out/etc/rucio.cfg

    runHook postInstall
  '';

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "Rucio configuration for the EIC collaboration";
    license = licenses.mit;
    homepage = "https://github.com/eic/containers";
    platforms = platforms.all;
    maintainers = with maintainers; [ veprbl ];
  };
}
