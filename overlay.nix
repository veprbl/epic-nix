final: prev: with final; {

  root = prev.root.overrideAttrs (prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      "-DCMAKE_CXX_STANDARD=17"
    ];
  });

  podio = callPackage pkgs/podio/default.nix {};

}
