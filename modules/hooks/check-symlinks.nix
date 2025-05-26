{ config, tools, lib, ... }:
{
  config = {
    name = "check-symlinks";
    description = "Find broken symlinks.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-symlinks";
    types = [ "symlink" ];
  };
}
