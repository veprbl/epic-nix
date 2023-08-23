{ self
, epic_pkgs
, pkgs
}:

let

  packages =
    (builtins.attrValues
      (pkgs.lib.filterAttrs
        (name: value: (name != "fun4all") && (pkgs.lib.isDerivation value))
        epic_pkgs));

  extra_packages = with pkgs; [
    # Development
    cmake
    gitFull
    nix
    stdenv.cc

    # Utilities
    bash
    cacert
    cachix
    coreutils
    curl
    emacs
    entr
    gawk
    gnugrep
    gnused
    jq
    less
    perl
    procps
    rsync
    silver-searcher
    vim
    which
    wget
    zsh

    # Libraries
    python3
    python3Packages.awkward
    python3Packages.dask
    python3Packages.distributed
    python3Packages.hepmc3
    python3Packages.matplotlib
    python3Packages.pyarrow
    python3Packages.scikit-learn
    python3Packages.pytorch
    python3Packages.uproot
    root

    # Continuous Integration
    github-runner
  ];

  container_env = pkgs.runCommandNoCC "container-env" {
    buildInputs = packages ++ extra_packages;
  } ''
    mkdir -p "$out/.singularity.d/env"
    declare -p | grep -vE "^declare -[ai-]" | grep -vE "^declare -. (PWD|OLDPWD|HOME|TMP|TEMP)" > "$out/.singularity.d/env/99-epic-nix.sh"
    cat > "$out/.singularity.d/env/99-epic-nix-config.sh" <<EOF
    unset NIX_STORE_DIR
    unset NIX_CONF_DIR
    unset NIX_STATE_DIR
    EOF
    mkdir -p "$out/etc/nix"
    cat > "$out/etc/nix/nix.conf" <<EOF
    experimental-features = flakes nix-command
    substituters = https://cache.nixos.org https://epic-eic.cachix.org
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= epic-eic.cachix.org-1:9Mu7fnayGYtapkzXm+7ZhPP5w7bJxtSv9C+BJTWon/o=
    EOF
  '';

in

  pkgs.dockerTools.buildLayeredImage {
    name = "epic-nix";
    contents = packages ++ extra_packages ++ [ container_env ];
  }
