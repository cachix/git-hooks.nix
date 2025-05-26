{ tools, lib, config, ... }:
{
  config = {
    name = "check-merge-conflicts";
    description = "Check for files that contain merge conflict strings.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-merge-conflict";
    types = [ "text" ];
  };
}
