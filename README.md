[![Build](https://github.com/veprbl/epic-nix/actions/workflows/build.yml/badge.svg?event=push)](https://github.com/veprbl/eic-nix/actions/workflows/build.yml)

Supported architectures:

  - `x86_64-linux` (Linux and possibly WSL2 on Windows)
  - `x86_64-darwin` (macOS)

Usage
=====

You will need a working installation of Nix which can be obtained [here](https://nixos.org/download.html#download-nix) (few [additional options](https://nix.dev/tutorials/install-nix) available).

An optional step is to enable the binary cache for this overlay:

```shell
nix-shell -p cachix --run "cachix use eic"
```

nix-shell
---------

A quick way to start using the packages is to clone the repository and invoke a
nix-shell, which will start a shell with environment that includes all the EIC
packages:

```shell
git clone https://github.com/veprbl/epic-nix.git
cd epic-nix
nix-shell
```

Flakes
------

Depending on the version of Nix that you have, you may have to first enable the following features:

```shell
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Similar to the **nix-shell** approach above, one can invoke the environment without cloning the repository:

```shell
nix develop github:veprbl/epic-nix
```

or with cloning:

```shell
git clone https://github.com/veprbl/epic-nix.git
cd epic-nix
nix develop
```
