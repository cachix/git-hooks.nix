{ config, tools, lib, ... }:
{
  config = {
    name = "check-yaml";
    description = "Check syntax of YAML files.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-yaml --multi";
    types = [ "yaml" ];
  };
}
