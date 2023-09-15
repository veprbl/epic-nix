{ lib
, stdenv
, acts-src
, boost
, cmake
, dd4hep
, eigen
, nlohmann_json
}:

stdenv.mkDerivation rec {
  pname = "acts";
  version = "21.1.0.${acts-src.shortRev}";

  src = acts-src;

  nativeBuildInputs = [
    cmake
  ];
  propagatedBuildInputs = [
    eigen
  ];
  buildInputs = [
    boost
    dd4hep
    nlohmann_json
  ];

  cmakeFlags = [
    "-DACTS_BUILD_PLUGIN_DD4HEP=ON"
    "-DACTS_BUILD_PLUGIN_JSON=ON"
    "-DACTS_USE_SYSTEM_BOOST=ON"
    "-DACTS_USE_SYSTEM_EIGEN3=ON"
    "-DACTS_USE_SYSTEM_NLOHMANN_JSON=ON"
  ];

  meta = with lib; {
    description = "Experiment-independent toolkit for (charged) particle track reconstruction in (high energy) physics experiments implemented in modern C++";
    license = licenses.mpl20;
    homepage = "https://github.com/acts-project/acts";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
