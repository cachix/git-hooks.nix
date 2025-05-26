{ config, tools, lib, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/detect-private-key";
    types = [ "text" ];
  };
}
