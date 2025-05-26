{ config, tools, lib, ... }:
{
  config = {
    package = tools.flake-checker;
    entry = "${config.package}/bin/flake-checker -f";
    files = "(^flake\.nix$|^flake\.lock$)";
    pass_filenames = false;
  };
}
