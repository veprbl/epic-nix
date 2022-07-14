{ lib
, stdenv
, fetchFromGitHub
, cmake
, dd4hep
}:

stdenv.mkDerivation rec {
  pname = "acts-dd4hep";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "acts-project";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-8mZ0SaCwCV0Xgw2vplMTkY7FRe7Ss6nfsPr7tA8pQvk=";
  };

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    dd4hep
  ];

  meta = with lib; {
    description = "Glue library to interface Acts to DD4hep";
    license = licenses.mpl20;
    homepage = "https://github.com/acts-project/acts-dd4hep";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
