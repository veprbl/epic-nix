{ lib
, stdenv
, edm4hep-src
, hepmc3
, catch2_3
, cmake
, podio
, python3
, root
}:

let

  catch2_WithMain = catch2_3.overrideAttrs (prev: rec {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCATCH_BUILD_STATIC_LIBRARY=ON"
    ];

    doCheck = false;
  });

in

stdenv.mkDerivation rec {
  pname = "EDM4hep";
  version = "00-10.${edm4hep-src.shortRev or "dirty"}";

  src = edm4hep-src;

  postPatch = ''
    patchShebangs .
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace cmake/EDM4HEPBuild.cmake \
      --replace 'set(CMAKE_INSTALL_NAME_DIR "@rpath")' "" \
      --replace 'set(CMAKE_INSTALL_RPATH "@loader_path/../lib")' ""
  '';

  nativeBuildInputs = [
    cmake
    python3
  ];
  propagatedBuildInputs = [
    podio
  ];
  buildInputs = [
    root
  ];
  checkInputs = [
    catch2_WithMain
    hepmc3
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  doInstallCheck = true;
  installCheckTarget = "test";
  preInstallCheck = let
    var_name = "${lib.optionalString stdenv.isDarwin "DY"}LD_LIBRARY_PATH";
  in ''
    export ${var_name}=${"$"}${var_name}:${placeholder "out"}/lib
  '';

  setupHook = ./setup-hook.sh;

  meta = with lib; {
    description = "Generic event data model for HEP collider experiments";
    license = licenses.asl20;
    homepage = "https://cern.ch/edm4hep";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
