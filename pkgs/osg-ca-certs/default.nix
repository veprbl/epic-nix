{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation rec {
  pname = "osg-ca-certs";
  version = "1.130";

  src = fetchurl {
    url = "https://repo.opensciencegrid.org/cadist/${version}NEW/osg-certificates-${version}NEW.tar.gz";
    hash = "sha256-R0+OpHOXzWoFvrihTFqVFRCjnlICzF/edXhyf3pduVc=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/etc/grid-security/certificates
    mv * "$out"/etc/grid-security/certificates/

    runHook postInstall
  '';

  meta = with lib; {
    changelog = "https://repo.opensciencegrid.org/cadist/CHANGES";
    description = "OSG CA certificates";
    license = licenses.unfreeRedistributable; # no license specified
    homepage = "https://ca.cilogon.org/";
    maintainers = with maintainers; [ veprbl ];
  };
}
