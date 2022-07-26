{ pkgs, providedPackageList, self, system }:

{
  dockerImage = pkgs.dockerTools.buildLayeredImage {
    name = "eic-nix";
    contents = map (name: self.packages.${system}.${name}) providedPackageList;
  };
}
