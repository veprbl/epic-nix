{ lib
, stdenv
, fetchurl
, podio-src
, catch2_3
, cmake
, fmt
, python3
, root
, makeWrapper
}:

let

  # instead of adding python3 and packages to propagatedNativeBuildInputs,
  # let's hardcode a wrapped python into the specific scripts
  python = python3.withPackages (pkgs: with pkgs; [ jinja2 pyyaml tabulate ]);

in

stdenv.mkDerivation rec {
  pname = "podio";
  version = "01-03.${podio-src.shortRev or "dirty"}";

  src = podio-src;

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];
  buildInputs = [
    fmt
    catch2_3
    python
    python3.pkgs.graphviz
    root
  ];

  # See comment above
  postPatch = ''
    substituteInPlace cmake/podioMacros.cmake \
      --replace "\''${Python_EXECUTABLE}" "${python}/bin/python"

    patchShebangs --host tools/ python/
    patchShebangs --build tests/

    # Calls via shebang are not advertised/used by upstream, but let's cover that
    # case as well
    chmod +x python/podio_class_generator.py # need to chmod for patchShebangs
    patchShebangs --host python/podio_class_generator.py

    # https://github.com/AIDASoft/podio/commit/8320d6ea2acf2467c4c05ee1f8b0a062af9829cb
    sed -i src/rootUtils.h -e '1i#include <sstream>'
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/podioBuild.cmake \
      --replace 'set(CMAKE_INSTALL_NAME_DIR "@rpath")' "" \
      --replace 'set(CMAKE_INSTALL_RPATH "@loader_path/../lib")' ""
  '';

  preConfigure = ''
    ${import ./test_input_files.nix { inherit fetchurl; }}
  '';

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
    "-DUSE_EXTERNAL_CATCH2=ON"
  ] ++ lib.optionals (!stdenv.isDarwin) [
    "-DBUILD_TESTING=ON"
  ];

  postInstall = ''
    wrapProgram "$out"/bin/podio-dump \
      --prefix PYTHONPATH : "$out/${python3.sitePackages}"
    wrapProgram "$out"/bin/podio-vis \
      --prefix PYTHONPATH : "$out/${python3.sitePackages}" \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  doInstallCheck = !stdenv.isDarwin;
  installCheckTarget = "test";

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "A C++ library to support the creation and handling of data models in particle physics";
    longDescription = ''
      PODIO, or plain-old-data I/O, is a C++ library to support the creation
      and handling of data models in particle physics. It is based on the idea
      of employing plain-old-data (POD) data structures wherever possible,
      while avoiding deep-object hierarchies and virtual inheritance. This is
      to both improve runtime performance and simplify the implementation of
      persistency services.
    '';
    license = licenses.gpl3Only;
    homepage = "https://github.com/AIDASoft/podio";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
