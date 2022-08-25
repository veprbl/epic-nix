{ lib
, stdenv
, fetchurl
, gfortran
}:

stdenv.mkDerivation rec {
  pname = "pythia6";
  version = "6.4.28";

  src = fetchurl {
    url = "https://root.cern.ch/download/pythia6.tar.gz";
    sha256 = "sha256-1hPcsnyQVxDi8TqTSRPMVUXj5dDkd+WAEHOF2e8mAFY=";
  };
  pythia6_src = fetchurl {
    urls = [
      "https://pythia.org/download/pythia6/pythia6428.f"
      "https://web.archive.org/web/20210603195336if_/https://pythia.org/download/pythia6/pythia6428.f"
    ];
    sha256 = "sha256-sG8mbgP3SC7Ov/1BhjPe3siqJbh3KuGeA4t1TX0zupk=";
  };

  nativeBuildInputs = [ gfortran ];

  CFLAGS="-fcommon";
  FFLAGS="-fcommon";
  LDFLAGS=if stdenv.isDarwin then "-dynamiclib" else "-shared";

  buildPhase = ''
    cp "$pythia6_src" pythia.f

    $FC $FFLAGS pythia.f -c -o pythia.o
    $FC $FFLAGS -fno-second-underscore tpythia6_called_from_cc.F -c -o tpythia6_called_from_cc.o
    $CC $CFLAGS pythia6_common_address.c -c -o pythia6_common_address.o
    $FC $LDFLAGS -o libPythia6${stdenv.hostPlatform.extensions.sharedLibrary} *.o
  '';

  installPhase = ''
    install -Dm444 libPythia6${stdenv.hostPlatform.extensions.sharedLibrary} \
      "$out"/lib/libPythia6${stdenv.hostPlatform.extensions.sharedLibrary}
  '';

  meta = with lib; {
    description = "The HEP Event Generator";
    license = licenses.unfree;
    homepage = "https://pythia.org/pythia6/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
