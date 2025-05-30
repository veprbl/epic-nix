{ lib
, stdenv
, edm4hep-src
, fetchpatch
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
  version = "00-99-01.${edm4hep-src.shortRev or "dirty"}";

  src = edm4hep-src;

  patches = [
    (fetchpatch {
      url = "https://github.com/key4hep/EDM4hep/commit/18799dacfdaf5d746134c957de48607aa2665d75.diff";
      hash = "sha256-Ab9xGicIKRkU1QcvCzsToUCEYhC6b3L8lsD5S7GO/po=";
    })
  ];

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
    "-DCMAKE_CXX_STANDARD=20"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
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
