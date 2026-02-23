{ pkgs, run }:
{
  installation-test = pkgs.callPackage ./installation.nix { inherit run; };
  hook-config-test = pkgs.callPackage ./hook-config.nix { inherit run; };
}
