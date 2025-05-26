{ config, tools, lib, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/forbid-new-submodules";
    types = [ "directory" ];
  };
}
