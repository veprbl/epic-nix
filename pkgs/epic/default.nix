{ lib
, stdenv
, epic-src
, epic-calibrations-cache
, cmake
, dd4hep
, fmt
, geant4-data
, irt2
, python3
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "epic";
  version = "26.07.2.${epic-src.shortRev or "dirty"}";

  src = epic-src;

  postPatch = ''
    patchShebangs --host bin/make_detector_configuration
  '';

  nativeBuildInputs = [
    cmake
    python3
    python3.pkgs.jinja2
    python3.pkgs.pyyaml
  ];
  buildInputs = [
    dd4hep
    fmt
    irt2
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20" # match dd4hep
    "-DEPIC_VERSION_FULL=${finalAttrs.version}"
  ];

  postInstall = ''
    mkdir -p $out/share/epic
    ln -s ${epic-calibrations-cache}/share/epic/calibrations-cache $out/share/epic/calibrations-cache
  '';

  setupHook = ./setup-hook.sh;

  passthru.tests.ddsim = stdenv.mkDerivation {
    pname = "epic-test-ddsim";
    inherit (finalAttrs) version;

    src = null;
    dontUnpack = true;
    dontWrapQtApps = true;

    nativeBuildInputs = [ dd4hep ];
    buildInputs = [ finalAttrs.finalPackage ] ++ lib.attrValues (lib.filterAttrs (_: v: lib.isDerivation v) geant4-data);

    buildPhase = ''
      source ${finalAttrs.finalPackage}/bin/thisepic.sh
      ddsim --runType batch \
        --compact "$DETECTOR_PATH/epic_craterlake_tracking_only.xml" \
        --enableGun \
        --gun.thetaMin "pi/2" \
        --gun.thetaMax "pi/2" \
        --gun.distribution uniform \
        --gun.phiMin "0*deg" \
        --gun.phiMax "0*deg" \
        --gun.energy "1*GeV" \
        --gun.particle "e-" \
        --numberOfEvents 10 \
        --outputFile output.edm4hep.root
    '';

    installPhase = ''
      mkdir -p $out
      cp output.edm4hep.root $out/
    '';
  };

  meta = with lib; {
    description = "DD4hep Geometry Description of the EPIC Experiment";
    license = licenses.lgpl3Only;
    homepage = "https://github.com/eic/epic";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
})
