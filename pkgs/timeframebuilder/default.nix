{ lib
, stdenv
, timeframebuilder-src
, cmake
, root
, podio
, edm4hep
, yaml-cpp
, hepmc3
, python3
}:

stdenv.mkDerivation rec {
  pname = "timeframebuilder";
  version = "0.9.1";

  src = timeframebuilder-src;

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'include(cmake/git_version.cmake)' 'set(TIMEFRAME_BUILDER_VERSION "${version}")' \
      --replace-fail 'set_git_version(TIMEFRAME_BUILDER_VERSION)' 'set(TIMEFRAME_BUILDER_VERSION_FULL "v${version}")' \
      --replace-fail 'link_directories(/opt/local/lib)' ""
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    root
    podio
    edm4hep
    yaml-cpp
    hepmc3
    python3
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = with lib; {
    description = "Tool for building timeframes from EDM4hep or HepMC3 inputs";
    license = licenses.unfree; # https://github.com/eic/TimeframeBuilder/issues/1
    homepage = "https://github.com/eic/TimeframeBuilder";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
