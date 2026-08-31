{ lib
, stdenv
, python3Packages
, cmake
, dd4hep
, edm4hep
, geant4
, podio
, time
, makeWrapper
, k4bench-src
}:

let
  geant4DataPackages = lib.attrValues (
    lib.filterAttrs (n: v: lib.isDerivation v) geant4.data
  );
in

python3Packages.buildPythonApplication rec {
  pname = "k4bench";
  version = "0.0.0+g${k4bench-src.shortRev or "dirty"}";
  pyproject = true;

  src = k4bench-src;

  postPatch = ''
    sed -i '/^    candidates = \[$/a\
            Path("${placeholder "out"}/lib/k4bench/plugin"),' k4bench/plugin/runtime.py
    substituteInPlace k4bench/runner/executor.py \
      --replace 'executable="/bin/bash"' 'executable="${stdenv.shell}"'
  '';

  build-system = with python3Packages; [ setuptools setuptools-scm ];
  dependencies = with python3Packages; [ pandas plotly requests ];

  dontUseCmakeConfigure = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    dd4hep
    edm4hep
    podio
  ] ++ geant4DataPackages;

  # Build the DD4hep timing plugins and install them into the path expected by
  # k4bench/plugin/runtime.py (plugin/install/lib or plugin/build).
  postBuild = ''
    cmake -S plugin -B plugin-build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$out/lib/k4bench/plugin/install \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -Wno-dev
    cmake --build plugin-build
  '';

  postInstall = ''
    cmake --install plugin-build
  '';

  postFixup = ''
    wrapProgram $out/bin/k4bench \
      --prefix PATH : "${lib.makeBinPath [ time ]}"
  '';

  meta = with lib; {
    description = "Performance benchmarking for DD4hep-based simulations and reconstruction in Key4hep";
    license = licenses.bsd3;
    homepage = "https://github.com/key4hep/k4Bench";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
