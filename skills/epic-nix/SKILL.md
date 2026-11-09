---
name: epic-nix
description: Use the epic-nix Nix flake (github:veprbl/epic-nix) to build and run EIC/ePIC software (DD4hep, epic geometry, npsim, EICrecon, EDM4eic, podio, ACTS, JANA2, juggler, ...). Covers swapping package sources with --override-input (local checkouts, branches, PRs, commits), predicting rebuild cost, and running an npsim + EICrecon simulation/reconstruction chain. Use when asked to test an EICrecon/epic/EDM4eic change with Nix, run ePIC simulation or reconstruction, or work on the epic-nix repository.
---

# epic-nix

`github:veprbl/epic-nix` is a Nix flake packaging the ePIC software stack. Every
upstream source is a **separate non-flake input** named `<package>-src`, so any
package can be pointed at a different source tree straight from the command line
with `--override-input`, with no edits to the flake.

Below, `FLAKE` means `github:veprbl/epic-nix` (or `.` inside a checkout of it).

## Outputs

| Output | What it is |
|---|---|
| `FLAKE#<pkg>` | packages: `acts algorithms afterburner aida dd4hep edm4eic edm4hep eicrecon eic-smear epic geant4 hepmcmerger irt irt2 jana2 juggler k4FWCore npsim podio root timeframebuilder ...` |
| `devShells.default` (`nix develop FLAKE`) | all packages + Geant4 data, `DETECTOR_PATH`/`DETECTOR_CONFIG` set from `thisepic.sh`. **Use this for npsim/ddsim.** |
| `FLAKE#eicrecon-env` | smaller shell: dd4hep, epic, eicrecon, podio, edm4*, root (no npsim, no Geant4 data) |
| `nix develop FLAKE#<pkg>` | the *build* environment of `<pkg>` (deps, no package itself); use it to hack on that package with cmake |
| `checks.<system>."epic.tests.ddsim"` | tiny ddsim smoke test |

`nix develop` runs the packages' setup hooks (e.g. epic's sources `bin/thisepic.sh`
to set `DETECTOR_PATH`); `nix shell` does not, so prefer `nix develop` for running things.

Run a command non-interactively: `nix develop FLAKE -c sh -c '...'`
(single-quote the script so `$DETECTOR_PATH` etc. expand *inside* the shell).

## Available `-src` inputs

```
acts-src algorithms-src dd4hep-src edm4eic-src edm4hep-src epic-src
epic-calibrations-cache-src eic-rucio-policy-package-src eicrecon-src geant4-src
hepmcmerger-src irt-src irt2-src jana2-src juggler-src npsim-src
osg-ca-certs-src podio-src timeframebuilder-src
```

Other inputs: `nixpkgs`, `site-overlay` (see below), `flake-compat`.

## `--override-input` cheat sheet

Syntax: `--override-input <input-name> <flake-ref>`; may be repeated; works with
`nix build`, `nix develop`, `nix run`, `nix shell`, `nix eval`, `nix flake lock`.

```shell
# upstream branch / tag / commit
--override-input eicrecon-src github:eic/EICrecon/main
--override-input epic-src     github:eic/epic/26.10.0
--override-input eicrecon-src github:eic/EICrecon/4a35e9ca08f303433940e738ae49f50e26f34444

# a GitHub pull request (note the refs/ prefix; "pull/N/head" alone fails with HTTP 422)
--override-input eicrecon-src github:eic/EICrecon/refs/pull/2099/head

# a fork
--override-input eicrecon-src github:someuser/EICrecon/my-branch

# a local checkout (see semantics below)
--override-input eicrecon-src /home/me/src/EICrecon          # git: tracked files incl. uncommitted edits
--override-input eicrecon-src git+file:///home/me/src/EICrecon?ref=my-branch   # committed state of a branch
--override-input eicrecon-src path:/home/me/src/EICrecon     # every file, incl. untracked
```

Local source semantics (verified):

- Plain path or `git+file://` of a git repo: **tracked files only, with working
  tree modifications included**; untracked files are ignored. `git add` new
  files (no commit needed) or they will be missing from the build.
- `path:` copies the whole directory, including untracked files and any
  `build/`/`prefix/` dirs. Slow with big build dirs and causes a rebuild on any
  change. Prefer the git form.
- With uncommitted changes the version shows `…-dirty`
  (`nix eval FLAKE#eicrecon.version --override-input …`); after commit it shows
  the short rev.

Behaviour to know about:

- `--override-input` does not modify `flake.lock` (nix prints "not writing
  modified lock file"). To pin an override persistently in a checkout:
  `nix flake lock --override-input eicrecon-src github:eic/EICrecon/<rev>`; to
  bump to the latest of the existing ref: `nix flake update eicrecon-src`.
- Version strings in `pkgs/*/default.nix` are hard-coded (e.g. `1.41.0-<rev>`);
  only the rev suffix follows the override. Not an issue for running it.
- Package recipes may carry `postPatch` substitutions/patches for the pinned
  version. A much newer/older source can fail in `postPatch`/configure. Then
  you need a local epic-nix checkout and an edit to `pkgs/<pkg>/default.nix`
  (or an overlay through `site-overlay`).
- `eicrecon` has `doInstallCheck = true` (runs its ctest suite during the build).
- Never override `nixpkgs` unless that is the point: it invalidates the
  binary cache for the entire stack (ROOT, Geant4, ... rebuild).
- `epic-calibrations-cache-src` feeds a fixed-output derivation with a pinned
  `outputHash`. Override `epic-src` freely, but leave
  `epic-calibrations-cache-src` alone unless calibration files changed (then
  you need to update the hash in `pkgs/epic/calibrations-cache.nix`).

### Estimate rebuild cost first

An override rebuilds that package **and everything depending on it**, and none
of it comes from the cache. Check before a long build:

```shell
nix build --dry-run FLAKE#eicrecon --override-input edm4eic-src github:eic/EDM4eic/main
# these 3 derivations will be built: EDM4eic, algorithms, EICrecon
```

Rough dependency picture (low → high): `geant4, root` → `podio` → `edm4hep` →
`edm4eic` → `algorithms` → `eicrecon`/`juggler`; `dd4hep` (needs geant4, root,
podio, edm4hep) → `epic`, `npsim`, `eicrecon`, `juggler`; `acts`, `jana2`,
`irt`, `irt2` → `eicrecon`. Leaf overrides (`eicrecon-src`, `epic-src`,
`npsim-src`) are cheap; `epic` is not a build input of `eicrecon` (geometry is
only loaded at runtime), so a geometry PR only rebuilds `epic`. Overriding
`podio-src`, `dd4hep-src` or `geant4-src` rebuilds most of the stack.

### Consuming epic-nix from another flake

```nix
inputs.epic-nix.url = "github:veprbl/epic-nix";
# pin a nested source:
inputs.epic-nix.inputs.eicrecon-src.url = "github:eic/EICrecon/main";
```

From the CLI, nested inputs use a slash path: `--override-input epic-nix/eicrecon-src ~/src/EICrecon`.
Don't make `epic-nix` follow your `nixpkgs` (`inputs.epic-nix.inputs.nixpkgs.follows`) unless you accept losing the cache.

### site-overlay

`site-overlay` is a flake whose `overlays.default` is applied on top of the
epic-nix overlay (default: an empty one). Use it to patch recipes without
forking:

```nix
# ~/my-overlay/flake.nix
{
  outputs = { self }: {
    overlays.default = final: prev: {
      eicrecon = prev.eicrecon.overrideAttrs (old: {
        cmakeFlags = old.cmakeFlags ++ [ "-DCMAKE_BUILD_TYPE=Debug" ];
        doInstallCheck = false;
      });
    };
  };
}
```

```shell
nix develop FLAKE --override-input site-overlay path:$HOME/my-overlay
```

## Common use cases

Run these in a scratch directory: EICrecon/DD4hep create `calibrations/`,
`fieldmaps/`, `gdml/` in the current directory.

### Simulate with npsim, reconstruct with EICrecon

The gun settings below (particle, energy, angular range, event count) are just
a placeholder for exercising the chain; pick values that match the use case
(e.g. a specific particle/energy for a detector study, a wide eta/theta range
for acceptance checks, more events for stable statistics) rather than reusing
this example as-is.

```shell
mkdir -p /tmp/epic-run && cd /tmp/epic-run
nix develop github:veprbl/epic-nix -c sh -c '
  npsim --compactFile $DETECTOR_PATH/$DETECTOR_CONFIG.xml \
    --runType batch --numberOfEvents 10 \
    --enableGun --gun.particle e- --gun.energy "5*GeV" \
    --gun.thetaMin "100*deg" --gun.thetaMax "170*deg" --gun.distribution uniform \
    --outputFile sim.edm4hep.root
  eicrecon -Ppodio:output_file=rec.edm4eic.root sim.edm4hep.root
'
```

(5 events of this take ~40 s of npsim + eicrecon with a warm cache.)

Variations:

- Other detector configurations: `ls $DETECTOR_PATH/*.xml` (e.g.
  `epic_craterlake_18x275.xml`, `epic_craterlake_tracking_only.xml` for fast tests).
  EICrecon uses `$DETECTOR_PATH/$DETECTOR_CONFIG.xml`; for a different one set
  `DETECTOR_CONFIG=epic_craterlake_18x275` before running both programs, or pass
  `-Pdd4hep:xml_files=...` to eicrecon.
- HepMC3 input instead of the gun: `npsim --inputFiles events.hepmc3.tree.root ...`
  (`afterburner`/`hepmcmerger` are also in the default shell).
- Limit output collections: `-Ppodio:output_collections=ReconstructedParticles,MCParticles`.
  Number of events/threads: `-Pjana:nevents=N -Pnthreads=N`.
- `npsim --help` / `eicrecon -h` for more options. eicrecon prints every
  parameter (key, value, default, description) in its log at startup.
- Default `DETECTOR_CONFIG` is `epic`; `source $DETECTOR_PATH/../../bin/thisepic.sh <config>`
  inside the shell switches it.

### Test an EICrecon PR or local change on that chain

```shell
nix develop github:veprbl/epic-nix \
  --override-input eicrecon-src github:eic/EICrecon/refs/pull/2099/head \
  -c sh -c 'eicrecon -Ppodio:output_file=rec.edm4eic.root sim.edm4hep.root'

# local working copy (git add new files first)
nix develop github:veprbl/epic-nix --override-input eicrecon-src ~/src/EICrecon -c ...
```

### Test a geometry (epic) change through sim + reco

```shell
nix develop github:veprbl/epic-nix --override-input epic-src ~/src/epic -c sh -c '
  echo $DETECTOR_PATH      # now points at the rebuilt epic
  npsim --compactFile $DETECTOR_PATH/$DETECTOR_CONFIG.xml ... --outputFile sim.edm4hep.root
  eicrecon -Ppodio:output_file=rec.edm4eic.root sim.edm4hep.root
'
```

Combine as many overrides as needed (e.g. `epic-src` + `eicrecon-src` +
`edm4eic-src` for a coordinated change across repos).

### Iterative development of EICrecon (no Nix rebuild per edit)

Nix builds are clean full builds; for edit-compile cycles use the package's
build environment and cmake directly:

```shell
cd ~/src/EICrecon
nix develop github:veprbl/epic-nix#eicrecon -c sh -c \
  'cmake -B build -S . -DCMAKE_INSTALL_PREFIX=$PWD/prefix && cmake --build build -j$(nproc) && cmake --install build'
```

Then run `prefix/bin/eicrecon` inside `nix develop github:veprbl/epic-nix`
(the default shell, so geometry is set up), with
`JANA_PLUGIN_PATH=$PWD/prefix/lib/EICrecon/plugins` so it loads *your* plugins
and not the packaged ones (the packaged `eicrecon` is a wrapper that only sets
`JANA_PLUGIN_PATH` if unset). Same pattern for other packages:
`nix develop FLAKE#epic`, `FLAKE#dd4hep`, ... When a dependency should also be
modified, add `--override-input <dep>-src ...` to that `nix develop` command.

