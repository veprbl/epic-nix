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

      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        # Will assume that the flake user agrees to use non-free EIC software
        config.allowUnfreePredicate = pkg: builtins.elem pkg.pname [ "athena" "ecce" "EICrecon" "eic-smear" "ip6" ];
      };

    in
    {

      overlays.default = import ./overlay.nix;

      packages = lib.genAttrs supportedSystems
        (system:
          let
            pkgs = pkgsFor system;
            providedPackageList = builtins.attrNames (self.overlays.default {} {});

            is_broken = pkg: (pkg.meta or {}).broken or false;
            select_unbroken = lib.filterAttrs (name: pkg: !(is_broken pkg));
          in
            select_unbroken (lib.getAttrs providedPackageList pkgs));

      checks = self.packages;

      # Default "development" shell provides all available packages (accessed via "nix develop")
      devShells = lib.genAttrs supportedSystems (system:
        let
          pkgs = pkgsFor system;
        in
          {
            default = pkgs.mkShell rec {
              buildInputs = builtins.attrValues self.packages.${system};
            };
          });

    };
}
