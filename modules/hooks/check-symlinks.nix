{ config, tools, lib, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-symlinks";
    types = [ "symlink" ];
  };
}
