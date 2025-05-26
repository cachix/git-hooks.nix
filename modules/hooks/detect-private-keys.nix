{ config, tools, lib, ... }:
{
  config = {
    name = "detect-private-keys";
    description = "Detect the presence of private keys.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/detect-private-key";
    types = [ "text" ];
  };
}
