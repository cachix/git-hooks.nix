{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-added-large-files";
    stages = [ "pre-commit" "pre-push" "manual" ];
  };
}
