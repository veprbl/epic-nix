# Available software

### DD4hep

### EICrecon

The `devShells.*.eicrecon-env` environment is available for running the latest packaged version of EICrecon:

```shell
nix develop github:veprbl/epic-nix#eicrecon-env -c sh -c "eicrecon sim.edm4hep.root"
```

To build EICrecon from source one can use the package environment instead:

```shell
git clone git@github.com:eic/EICrecon.git
cd EICrecon
nix develop github:veprbl/epic-nix#eicrecon -c sh -c "cmake -B build -S . -DCMAKE_INSTALL_PREFIX=$PWD/prefix && cmake --build build && cmake --install build"
```
