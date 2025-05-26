{ config, tools, lib, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/fix-encoding-pragma";
    types = [ "python" ];
  };
}
