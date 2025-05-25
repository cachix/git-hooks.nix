{ tools, lib, ... }:
{
  config = {
    name = "check-yaml";
    description = "Check syntax of YAML files.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-yaml --multi";
    types = [ "yaml" ];
  };
}