{ tools, lib, ... }:
{
  config = {
    name = "nixpkgs-fmt";
    description = "Nix code formatter for nixpkgs.";
    package = tools.nixpkgs-fmt;
    entry = "${tools.nixpkgs-fmt}/bin/nixpkgs-fmt";
    files = "\.nix$";
  };
}