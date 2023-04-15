{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
, root
, xercesc
, zeromq
}:

stdenv.mkDerivation rec {
  pname = "jana2";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "JeffersonLab";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-mE7CWtlYzs1BY25VIVHIKPYTIIWpXOuPd2LopXOldG8=";
  };

  postPatch = lib.optionalString stdenv.isDarwin ''
    cat >> src/libraries/JANA/Services/JParameterManager.h <<EOF
    #pragma once
    template <>
    inline std::vector<unsigned long> JParameterManager::parse(const std::string& value) {
        return parse_vector<unsigned long>(value);
    }
    template<>
    inline std::string JParameterManager::stringify(const std::vector<unsigned long>& values) {
        return stringify_vector(values);
    }
    EOF
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    python3
    python3.pkgs.pybind11
    root
    xercesc
    zeromq
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DUSE_ROOT=ON"
    "-DUSE_ZEROMQ=ON"
    "-DUSE_XERCES=ON"
    "-DUSE_PYTHON=ON"
    "-DXercesC_DIR=${xercesc}"
  ];

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isDarwin [
    # error: aligned allocation function of type '...' is only available on macOS 10.14 or newer
    "-faligned-allocation"
  ];

  meta = with lib; {
    description = "Multi-threaded HENP Event Reconstruction";
    longDescription = ''
      JANA is a C++ framework for multi-threaded HENP (High Energy and Nuclear
      Physics) event reconstruction. It is very efficient at multi-threading
      with a design that makes it easy for less experienced programmers to
      contribute pieces to the larger reconstruction project. The same JANA
      program can be used to easily do partial or full reconstruction, fully
      maximizing the available cores for the current job.
    '';
    license = licenses.bsd3;
    homepage = "https://jeffersonlab.github.io/JANA2/";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
