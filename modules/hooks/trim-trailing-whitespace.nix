{ tools, lib, config, ... }:
{
  config = {
    types = [ "text" ];
    stages = [ "pre-commit" "pre-push" "manual" ];
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/trailing-whitespace-fixer";
  };
}
