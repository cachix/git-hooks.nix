{ tools, lib, config, ... }:
{
  config = {
    package = tools.nil;
    entry = "${config.package}/bin/nil";
    files = "\.nix$";
  };
}
