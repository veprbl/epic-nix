{ epic_pkgs, pkgs, self }:

let

  extra_packages = with pkgs; [
    # Development
    clang-tools
    cmake
    gitFull
    nix
    stdenv.cc

    # Utilities
    bash
    cachix
    coreutils
    curl
    emacs
    entr
    gawk
    gnugrep
    gnused
    jq
    lorri
    perl
    rsync
    silver-searcher
    vim
    wget
    zsh

    # Libraries
    (python3.withPackages (ps: with ps; [
      awkward
      hepmc3
      matplotlib
      pyarrow
      scikit-learn
      scipy
      tensorflow
      pytorch
      uproot
      yoda
    ]))
    root

    # Event Generators
    herwig
    pythia
    rivet
    sacrifice # run-pythia
    sherpa
  ];

in

{
  dockerImage = pkgs.dockerTools.buildLayeredImage {
    name = "epic-nix";
    contents =
      (builtins.attrValues (pkgs.lib.filterAttrs (name: value: (name != "ecce") && (pkgs.lib.isDerivation value)) epic_pkgs))
      ++ extra_packages;
  };
}
