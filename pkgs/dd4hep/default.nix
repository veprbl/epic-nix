{ lib
, stdenv
, fetchpatch
, dd4hep-src
, assimp
, boost
, bzip2
, cmake
, edm4hep
, geant4
, hepmc3
, xz
, zlib
, gnugrep
, python3
, root
, AGL
, OpenGL
}:

stdenv.mkDerivation rec {
  pname = "DD4hep";
  version = "01-30.${dd4hep-src.shortRev or "dirty"}";

  src = dd4hep-src;

  patches = [
    (fetchpatch {
      url = "https://patch-diff.githubusercontent.com/raw/AIDASoft/DD4hep/pull/1365.diff";
      hash = "sha256-K/3W9J5JWbnyDmegPCQkxWZ7YjfzlQ2MFuKwrmto4Yc=";
    })
  ];

  postPatch = ''
    patchShebangs --host .

    substituteInPlace CMakeLists.txt \
      --replace "find_package(podio 0.16.3 REQUIRED)" "find_package(podio REQUIRED)"
    substituteInPlace cmake/thisdd4hep.sh \
      --replace "grep" "${gnugrep}/bin/grep"

    substituteInPlace DDG4/python/DDSim/DD4hepSimulation.py \
      --replace "if not os.path.exists(fileName):" "if False:"
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/DD4hepBuild.cmake \
      --replace 'set(CMAKE_INSTALL_NAME_DIR "@rpath")' "" \
      --replace 'set(CMAKE_INSTALL_RPATH "@loader_path/../lib")' "" \
      --replace 'SET(Python_FIND_FRAMEWORK LAST)' 'set(Python_FIND_FRAMEWORK NEVER)'
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
    xz
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
    "-DCMAKE_CXX_STANDARD=20" # match geant4
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

  CXXFLAGS = lib.optionals stdenv.cc.isClang [ "-Wno-error=c++11-narrowing" ];

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
