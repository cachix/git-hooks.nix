{ tools, lib, ... }:
{
  config = {
    name = "check-merge-conflicts";
    description = "Check for files that contain merge conflict strings.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-merge-conflict";
    types = [ "text" ];
  };
}