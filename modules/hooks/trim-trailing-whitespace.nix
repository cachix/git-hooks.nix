{ tools, lib, config, ... }:
{
  config = {
    name = "trailing-whitespace";
    description = "Trim trailing whitespace.";
    types = [ "text" ];
    stages = [ "pre-commit" "pre-push" "manual" ];
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/trailing-whitespace-fixer";
  };
}
