{ tools, lib, ... }:
{
  config = {
    name = "nil";
    description = "Incremental analysis assistant for writing in Nix.";
    package = tools.nil;
    entry = "${tools.nil}/bin/nil";
    files = "\.nix$";
  };
}