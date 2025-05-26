{ tools, lib, config, ... }:
{
  config = {
    name = "nil";
    description = "Incremental analysis assistant for writing in Nix.";
    package = tools.nil;
    entry = "${config.package}/bin/nil";
    files = "\.nix$";
  };
}
