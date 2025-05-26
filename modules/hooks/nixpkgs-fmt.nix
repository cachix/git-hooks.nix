{ tools, lib, config, ... }:
{
  config = {
    package = tools.nixpkgs-fmt;
    entry = "${config.package}/bin/nixpkgs-fmt";
    files = "\.nix$";
  };
}
