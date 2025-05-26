{ config, tools, lib, ... }:
{
  config = {
    name = "forbid-new-submodules";
    description = "Prevent addition of new Git submodules.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/forbid-new-submodules";
    types = [ "directory" ];
  };
}
