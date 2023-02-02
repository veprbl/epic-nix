{ lib
, stdenv
, fetchFromGitHub
, acts-dd4hep
, boost
, cmake
, dd4hep
, eigen
, nlohmann_json
}:

stdenv.mkDerivation rec {
  pname = "acts";
  version = "20.3.0";

  src = fetchFromGitHub {
    owner = "acts-project";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-bbCBcv9KHtid0+EeUVTnEVH5WimVfbcL78To5c0JkfE=";
  };

  nativeBuildInputs = [
    cmake
  ];
  propagatedBuildInputs = [
    acts-dd4hep
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
    "-DACTS_USE_SYSTEM_ACTSDD4HEP=ON"
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
