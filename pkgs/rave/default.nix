{ lib
, stdenv
, fetchurl
, boost
, clhep
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "rave";
  version = "0.6.9";

  src = fetchurl {
    name = "rave-${version}.tar.gz";
    url = "https://rave.hepforge.org/downloads/?f=rave-${version}.tar.gz";
    hash = "sha256-eEmT0lWoNavgYd9X6XrsaluFvdkPhYgBySxPZ4vOKRU=";
  };

  patches = [
    # Fixes for compilation with clang
    ./fixes.patch

    # Switch from vendored boost::shared_ptr to std::shared_ptr
    ./std_shared_ptr.patch
  ];

  configureFlags = [
    "--disable-java"
    "--with-clhep_vector-libpath=${clhep}/lib"
    "--with-clhep_matrix-libpath=${clhep}/lib"
  ];

  CPPFLAGS="-DDISABLE_GNU_EXTENSIONS";
  CXXFLAGS="-std=c++11 -Wno-enum-constexpr-conversion";

  nativeBuildInputs = [
    pkg-config
  ];
  propagatedBuildInputs = [
    boost
  ];
  buildInputs = [
    boost
    clhep
  ];

  meta = with lib; {
    description = "Reconstruction in an Abstract, Versatile Environment";
    license = licenses.gpl2Only;
    homepage = "https://rave.hepforge.org/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
