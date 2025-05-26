{ tools, lib, config, ... }:
{
  config = {
    name = "check-added-large-files";
    description = "Prevent very large files to be committed (e.g. binaries).";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-added-large-files";
    stages = [ "pre-commit" "pre-push" "manual" ];
  };
}
