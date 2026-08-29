{ lib
, stdenv
, python3Packages
, cmake
, dd4hep
, geant4
, root
, time
, makeWrapper
, writeShellScript
, k4bench-src
}:

let
  geant4DataPackages = lib.attrValues (
    lib.filterAttrs (n: v: lib.isDerivation v) geant4.data
  );
  geant4DataPathsStr = lib.concatStringsSep " " geant4DataPackages;
  setupEnv = writeShellScript "k4bench-setup-env" ''
    source ${root}/bin/thisroot.sh
    source ${geant4}/bin/geant4.sh
    for pkg in ${geant4DataPathsStr}; do
      eval "$(grep -E '^\s*export G4' "''$pkg/nix-support/setup-hook")"
    done
    source ${dd4hep}/bin/thisdd4hep.sh
  '';
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
    # k4bench invokes ddsim, which expects the ROOT/Geant4/DD4hep environment
    # that is normally set up by sourcing thisroot.sh, geant4.sh (with data
    # environment variables) and thisdd4hep.sh. The Python wrapper created by
    # buildPythonApplication already sets PYTHONPATH for k4bench; re-wrap it to
    # source the setup scripts before launching.
    mv $out/bin/k4bench $out/bin/.k4bench-wrapped-app
    makeShellWrapper $out/bin/.k4bench-wrapped-app $out/bin/k4bench \
      --run ". ${setupEnv}" \
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
