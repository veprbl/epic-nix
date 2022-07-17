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

    in
    {

      overlays.default = import ./overlay.nix;

      packages = lib.genAttrs supportedSystems
        (system:
          let
            pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
            providedPackageList = builtins.attrNames (self.overlays.default {} {});
          in
            lib.getAttrs providedPackageList pkgs);

      checks = self.packages;

    };
}
