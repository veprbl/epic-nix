{ lib
, stdenv
, fetchFromGitHub
, fetchpatch2
, acts-src
, boost
, cmake
, dd4hep
, fmt
, hepmc3
, eigen
, nlohmann_json
, python3
, tbb
}:

stdenv.mkDerivation (self: with self; {
  pname = "acts";
  version = "39.2.1.${acts-src.shortRev or "dirty"}";

  src = acts-src;

  patches = [
    (fetchpatch2 {
      url = "https://github.com/acts-project/acts/pull/4456.patch?full_index=1";
      hash = "sha256-VT02Z9ywkCAgCofFy7btQf+J27LIvs+gsRvoeJaqyUg=";
    })
    (fetchpatch2 {
      url = "https://github.com/acts-project/acts/pull/4496.diff?full_index=1";
      hash = "sha256-r65LzB3bb3kL7oIjaD2fZ5l+gmmttUXHqXJnHh3+Ccs=";
    })
    (fetchpatch2 {
      url = "https://github.com/acts-project/acts/pull/4502.diff?full_index=1";
      hash = "sha256-EMllmNTkhJgG0JLjCc+Dcibs3s7LlMvEOY1XPPD7SNk=";
    })
    (fetchpatch2 {
      url = "https://raw.githubusercontent.com/eic/eic-spack/refs/heads/develop/packages/acts/pr4620.patch";
      hash = "sha256-mPAJ7BMpX8WzjGw4fELLcC6CRP/J24PrYclab26XKn4=";
    })
  ];

  postPatch = ''
    if [ -f cmake/ActsCodegen.cmake ]; then
      substituteInPlace cmake/ActsCodegen.cmake \
        --replace-warn 'if(uv_exe STREQUAL "uv_exe-NOTFOUND")' 'if(FALSE)' \
        --replace-warn '${"$"}{ARGS_PYTHON_VERSION}' '${python3.interpreter}' \
        --replace-warn 'env -i ''${uv_exe} run --quiet --python' "" \
        --replace-warn 'env -i UV_NO_CACHE=1 ''${uv_exe} run --quiet --python' "" \
        --replace-warn '--no-project ''${_arg_isolated} ''${_with_args}' ""
      export PYTHONPATH="$PWD/codegen/src:$PYTHONPATH"
    fi
  '';

  nativeBuildInputs = [
    cmake
  ];
  propagatedBuildInputs = [
    eigen
  ];
  buildInputs = [
    boost
    dd4hep
    fmt
    hepmc3
    nlohmann_json
    python3
    python3.pkgs.numpy
    python3.pkgs.particle
    python3.pkgs.pybind11
    python3.pkgs.sympy
    tbb
  ];

  dfelibs = fetchFromGitHub {
    owner = "acts-project";
    repo = "dfelibs";
    rev = "refs/tags/v20200416";
    hash = "sha256-05SyOw15QzEBbpyhU9er0rr4i5PCWKjBIedfTl55gGk=";
  };

  cmakeFlags = [
    "-DACTS_BUILD_EXAMPLES=ON"
    "-DACTS_BUILD_PLUGIN_DD4HEP=ON"
    "-DACTS_BUILD_PLUGIN_JSON=ON"
    "-DACTS_BUILD_EXAMPLES_DD4HEP=ON"
    "-DACTS_BUILD_EXAMPLES_GEANT4=ON"
    "-DACTS_BUILD_EXAMPLES_PYTHON_BINDINGS=ON"
    "-DACTS_USE_SYSTEM_BOOST=ON"
    "-DACTS_USE_SYSTEM_EIGEN3=ON"
    "-DACTS_USE_SYSTEM_NLOHMANN_JSON=ON"
    "-DACTS_USE_SYSTEM_PYBIND11=ON"
    "-DACTS_USE_SYSTEM_LIBS=ON"
    "-DFETCHCONTENT_SOURCE_DIR_DFELIBS=${dfelibs}"
    "-DPython_FIND_FRAMEWORK=NEVER" # fix for missing sandboxing on GitHub actions
  ];

  postInstall = ''
    mkdir -p "$(dirname "$out/${python3.sitePackages}")"
    ln -s "$out/python" "$out/${python3.sitePackages}"
  '';

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=missing-template-arg-list-after-template-kw";

  meta = with lib; {
    description = "Experiment-independent toolkit for (charged) particle track reconstruction in (high energy) physics experiments implemented in modern C++";
    license = licenses.mpl20;
    homepage = "https://github.com/acts-project/acts";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
})
