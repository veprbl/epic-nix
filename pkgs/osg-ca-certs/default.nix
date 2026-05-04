{
  lib,
  stdenv,
  osg-ca-certs-src,
}:

stdenv.mkDerivation rec {
  name = "osg-ca-certs";
  pname = "osg-ca-certs";

  src = osg-ca-certs-src;

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
