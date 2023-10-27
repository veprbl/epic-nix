{ lib
, stdenv
, dd4hep-src
, fetchpatch
, assimp
, boost
, bzip2
, cmake
, edm4hep
, geant4
, hepmc3
, lzma
, zlib
, gnugrep
, python3
, root
, AGL
, OpenGL
}:

stdenv.mkDerivation rec {
  pname = "DD4hep";
  version = "01-26.${dd4hep-src.shortRev or "dirty"}";

  src = dd4hep-src;

  patches = [
    # HepMC3FileReader.cpp: avoid double call to HepMC3::Reader::close()
    (fetchpatch {
      name = "dd4hep-xrd-fix.patch";
      url = "https://github.com/AIDASoft/DD4hep/commit/94994604256b248f91e345a109131498fa15dd1a.diff";
      hash = "sha256-EzTBmxAv8LiuGmb4yBUIMfouX1Ls1wtxVtG4kVxnVzE=";
    })

    # Geant4Output2EDM4hep: allow reuse of collection names... again
    (fetchpatch {
      name = "dd4hep-tracking-collection-fix.patch";
      url = "https://github.com/AIDASoft/DD4hep/commit/81254eae004f1a54a60d1df5ad06e0db342b04cd.diff";
      hash = "sha256-jOYKfMvEm70MPfYfkeI1sCiUfWp8NnqS4Ir20RJIa3k=";
    })

    # https://github.com/AIDASoft/DD4hep/pull/1161
    (fetchpatch {
      name = "dd4hep-hexgrid-support.patch";
      url = "https://github.com/AIDASoft/DD4hep/commit/03a54fdb313fb507448327269712851bc809b3ca.diff";
      hash = "sha256-HLcweBL37eHQ+DuyjCe1fWfNSw3zoFCMr5IkNOEw6rI=";
    })

    ./hexgrid_fix.patch
  ];

  postPatch = ''
    patchShebangs --host .

    substituteInPlace cmake/thisdd4hep.sh \
      --replace "grep" "${gnugrep}/bin/grep"

    substituteInPlace DDCore/CMakeLists.txt \
      --replace "ROOT::ROOTHistDraw" ""

    substituteInPlace DDG4/edm4hep/Geant4Output2EDM4hep.cpp \
      --replace "setValues" "setValue" \
      --replace "hits = m_calorimeterHits[colName] = edm4hep::SimTrackerHitCollection()" "hits = m_calorimeterHits[colName]"
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/DD4hepBuild.cmake \
      --replace 'set(CMAKE_INSTALL_NAME_DIR "@rpath")' "" \
      --replace 'set(CMAKE_INSTALL_RPATH "@loader_path/../lib")' ""
    substituteInPlace cmake/DD4hep.cmake \
      --replace \
      'set(''${ENV_VAR}_VALUE $<TARGET_FILE_DIR:''${library}>:$<TARGET_FILE_DIR:DD4hep::DD4hepGaudiPluginMgr>)' \
      'set(''${ENV_VAR}_VALUE $<TARGET_FILE_DIR:''${library}>:$<TARGET_FILE_DIR:DD4hep::DD4hepGaudiPluginMgr>:''$ENV{''${ENV_VAR}})'
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    assimp
    bzip2
    edm4hep
    geant4
    hepmc3
    lzma
    zlib
  ];
  propagatedBuildInputs = [
    boost
    python3
    root
  ] ++ lib.optionals (stdenv.isDarwin && geant4.enableQt) [
    # FIXME These should not be needed
    AGL
    OpenGL
  ];

  # not every executable is a binary - process them manually
  dontWrapQtApps = true;
  postFixup = lib.optionalString geant4.enableQt ''
    for file in $(find "$out"/bin -type f -executable); do
      wrapQtApp "$file"
    done
  '';

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17" # match geant4
    "-DDD4HEP_HEPMC3_COMPRESSION_SUPPORT=ON"
    "-DDD4HEP_USE_EDM4HEP=ON"
    "-DDD4HEP_USE_HEPMC3=ON"
    "-DDD4HEP_USE_GEANT4=ON"
    "-DBUILD_TESTING=ON"
  ];

  doInstallCheck = true;
  installCheckTarget = "test";
  installCheckInputs = [
    geant4.data.G4EMLOW
    geant4.data.G4ENSDFSTATE
    geant4.data.G4PARTICLEXS
    geant4.data.G4PhotonEvaporation
    python3.pkgs.pytest
  ];

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "Detector Description Toolkit for High Energy Physics";
    longDescription = ''
      DD4hep is a software framework for providing a complete solution for full
      detector description (geometry, materials, visualization, readout,
      alignment, calibration, etc.) for the full experiment life cycle
      (detector concept development, detector optimization, construction,
      operation). It offers a consistent description through a single source of
      detector information for simulation, reconstruction, analysis, etc.
    '';
    license = licenses.lgpl3Only;
    homepage = "http://dd4hep.cern.ch/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
