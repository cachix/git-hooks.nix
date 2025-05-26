{ config, tools, lib, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-toml";
    types = [ "toml" ];
  };
}
