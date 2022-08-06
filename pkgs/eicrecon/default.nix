{ lib
, stdenv
, fetchFromGitHub
, acts
, boost
, cmake
, dd4hep
, ecce
, edm4hep
, fmt
, ip6
, jana2
, podio
, root
}:

stdenv.mkDerivation rec {
  pname = "EICrecon";
  version = "unstable-2022-07-17";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "3cc1276bebc158c55c20886fab581c0f1bea6fcd";
    hash = "sha256-WEuH0BtOwcXItVFfP05LsAxPmLn/rPhLOrPqn8HrXfM=";
  };

  postPatch = ''
    substituteInPlace GEOMETRY/plugins/jana_dd4hep/CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX $ENV{JANA_HOME} CACHE PATH "magic incantation" FORCE)' ""
    substituteInPlace I_O/plugins/jana_edm4hep/CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX $ENV{JANA_HOME} CACHE PATH "magic incantation" FORCE)' ""
    substituteInPlace RECON/plugins/BarrelEMCal/CMakeLists.txt \
      --replace 'set(CMAKE_INSTALL_PREFIX $ENV{JANA_HOME} CACHE PATH "magic incantation" FORCE)' ""

    substituteInPlace GEOMETRY/plugins/jana_dd4hep/CMakeLists.txt \
      --replace 'target_include_directories(jana_dd4hep_plugin PUBLIC ''${CMAKE_SOURCE_DIR}' \
                'target_include_directories(jana_dd4hep_plugin PUBLIC ''${CMAKE_CURRENT_SOURCE_DIR} ''${CMAKE_CURRENT_SOURCE_DIR}/..'
    substituteInPlace RECON/plugins/BarrelEMCal/CMakeLists.txt \
      --replace 'target_link_libraries(BarrelEMCal_plugin ''${JANA_LIB})' \
                'target_link_libraries(BarrelEMCal_plugin ''${JANA_LIB} EDM4HEP::edm4hep fmt::fmt jana_dd4hep_plugin)'
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    acts
    boost
    dd4hep
    edm4hep
    fmt
    jana2
    podio
    root
  ];
  EDM4HEP_ROOT=edm4hep;
  EIC_DD4HEP_HOME=ecce;
  IP6_DD4HEP_HOME=ip6;

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    broken = true;
    description = "EIC Reconstruction - JANA based";
    longDescription = ''
    '';
    license = licenses.unfree; # https://github.com/eic/EICrecon/issues/2
    homepage = "https://github.com/eic/EICrecon";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
