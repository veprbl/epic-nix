{ lib
, stdenv
, fetchFromGitHub
, boost
, cmake
, geant4
, python3
, root
}:

stdenv.mkDerivation rec {
  pname = "DD4hep";
  version = "01-20-02";

  src = fetchFromGitHub {
    owner = "AIDASoft";
    repo = "DD4hep";
    rev = "v${version}";
    hash = "sha256-Bl3QO87n+R8gJ3B6+n2IZ7NTzlwbafXDAviyX3Q4IT0=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/DD4hepBuild.cmake \
      --replace 'set(CMAKE_INSTALL_NAME_DIR "@rpath")' "" \
      --replace 'set(CMAKE_INSTALL_RPATH "@loader_path/../lib")' ""
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    geant4
  ];
  propagatedBuildInputs = [
    boost
    python3
    root
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
    "-DDD4HEP_USE_GEANT4=ON"
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
