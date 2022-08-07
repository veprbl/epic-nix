{ lib
, stdenv
, fetchFromGitHub
, acts
, boost
, cmake
, dd4hep
, edm4hep
, epic
, fmt
, ip6
, jana2
, podio
, root
}:

stdenv.mkDerivation rec {
  pname = "EICrecon";
  version = "unstable-2022-08-06";

  src = fetchFromGitHub {
    owner = "eic";
    repo = pname;
    rev = "fd07190ab0267ea45b06ce266c4c658109475b47";
    hash = "sha256-k83t7bD7F+Yz0I+RevT9GMm57tlMMALk34Fr5Fh22Fs=";
  };

  postPatch = ''
    cd src/
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
  EIC_DD4HEP_HOME=epic;
  IP6_DD4HEP_HOME=ip6;

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
  ];

  meta = with lib; {
    description = "EIC Reconstruction - JANA based";
    license = licenses.unfree; # https://github.com/eic/EICrecon/issues/2
    homepage = "https://github.com/eic/EICrecon";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
