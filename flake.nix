{
  description = "Nix overlay for EIC";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, ... }:
    let

      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      overlay = import ./overlay.nix;
      providedPackages = builtins.attrNames (overlay {} {});

    in
    {

      overlays.default = overlay;

      packages = lib.genAttrs supportedSystems
        (system:
          let
            pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
          in
            lib.getAttrs providedPackages pkgs);

    };
}
