{ lib
, stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "AIDA";
  version = "3.2.1";

  src = fetchurl {
    urls = [
      "https://distfiles.macports.org/aida/aida-${version}.tar.gz"
      "ftp://ftp.slac.stanford.edu/software/freehep/AIDA/v${version}/aida-${version}.tar.gz"
    ];
    hash = "sha256-xR2oPpnAmFp+8+i8WmDDrmHzymA7YRAMJDi0za3Vuy4=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/include
    cp -r src/cpp/AIDA "$out"/include/
    cp -r lib "$out"/lib

    runHook postInstall
  '';

  meta = with lib; {
    description = "Abstract Interfaces for Data Analysis";
    longDescription = ''
      The goals of the AIDA project are to define abstract interfaces for
      common physics analysis objects, such as histograms, ntuples, fitters, IO
      etc..  The adoption of these interfaces should make it easier for
      physicists to use different tools without having to learn new interfaces
      or change all of their code. Additional benefits will be interoperability
      of AIDA compliant applications (for example by making it possible for
      applications to exchange analysis objects via XML).
    '';
    license = licenses.lgpl2;
    homepage = "https://aida.freehep.org/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
