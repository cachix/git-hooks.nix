{ config, tools, lib, ... }:
{
  config = {
    name = "check-toml";
    description = "Check syntax of TOML files.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-toml";
    types = [ "toml" ];
  };
}
