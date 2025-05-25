{ tools, lib, ... }:
{
  config = {
    name = "check-case-conflicts";
    description = "Check for files that would conflict in case-insensitive filesystems.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-case-conflict";
    types = [ "file" ];
  };
}