{ lib
, python3
, eic-rucio-policy-package-src
}:

python3.pkgs.buildPythonPackage rec {
  pname = "eic-rucio-policy-package";
  version = "0.1.2";
  pyproject = true;

  src = eic-rucio-policy-package-src;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "%version%" "${version}"
  '';

  build-system = [
    python3.pkgs.setuptools
  ];

  pythonImportsCheck = [
    "eic_rucio_policy_package"
  ];

  meta = with lib; {
    description = "Rucio policy package for the EIC collaboration";
    license = licenses.asl20;
    homepage = "https://github.com/eic/eic_rucio_policy_package";
    platforms = platforms.unix;
    maintainers = with maintainers; [ veprbl ];
  };
}
