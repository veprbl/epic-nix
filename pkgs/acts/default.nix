{ lib
, stdenv
, fetchFromGitHub
, acts-src
, boost
, cmake
, dd4hep
, eigen
, nlohmann_json
, tbb
}:

stdenv.mkDerivation (self: with self; {
  pname = "acts";
  version = "31.2.0.${acts-src.shortRev or "dirty"}";

  src = acts-src;

  postPatch = ''
    sed -i Core/include/Acts/Seeding/SeedFinderConfig.hpp -e '1i#include <vector>'
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace Core/include/Acts/Propagator/ConstrainedStep.hpp \
      --replace "constexpr" ""
    substituteInPlace Fatras/include/ActsFatras/EventData/Particle.hpp \
      --replace "constexpr" ""
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
    nlohmann_json
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
    "-DACTS_USE_SYSTEM_BOOST=ON"
    "-DACTS_USE_SYSTEM_EIGEN3=ON"
    "-DACTS_USE_SYSTEM_NLOHMANN_JSON=ON"
    "-DFETCHCONTENT_SOURCE_DIR_DFELIBS=${dfelibs}"
    "-DPython_FIND_FRAMEWORK=NEVER" # fix for missing sandboxing on GitHub actions
  ];

  meta = with lib; {
    description = "Experiment-independent toolkit for (charged) particle track reconstruction in (high energy) physics experiments implemented in modern C++";
    license = licenses.mpl20;
    homepage = "https://github.com/acts-project/acts";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
})
