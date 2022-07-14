{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, root
}:

let

  # instead of adding python3 and packages to propagatedNativeBuildInputs,
  # let's hardcode a wrapped python into the specific scripts
  python = python3.withPackages (pkgs: with pkgs; [ jinja2 pyyaml ]);

in

stdenv.mkDerivation rec {
  pname = "podio";
  version = "00-14-03";

  src = fetchFromGitHub {
    owner = "AIDASoft";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-beJXYggUQLfBtxWcmzj9oWVQasU8EzDoo+mxcTuXWkw=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    python
    root
  ];

  # See comment above
  postPatch = ''
    substituteInPlace cmake/podioMacros.cmake \
      --replace "\''${Python_EXECUTABLE}" "${python}/bin/python"
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/podioBuild.cmake \
      --replace 'set(CMAKE_INSTALL_NAME_DIR "@rpath")' "" \
      --replace 'set(CMAKE_INSTALL_RPATH "@loader_path/../lib")' ""
  '';

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  # Calls via shebang are not advertised/used by upstream, but let's cover that
  # case as well
  postInstall = ''
    # need to chmod for patchShebangs
    chmod +x "$out"/python/podio_class_generator.py
    patchShebangs --host "$out"/python/podio_class_generator.py
  '';

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
