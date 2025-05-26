{ tools, lib, config, ... }:
{
  config = {
    name = "nixpkgs-fmt";
    description = "Nix code formatter for nixpkgs.";
    package = tools.nixpkgs-fmt;
    entry = "${config.package}/bin/nixpkgs-fmt";
    files = "\.nix$";
  };
}
