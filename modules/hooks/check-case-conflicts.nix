{ tools, lib, config, ... }:
{
  config = {
    name = "check-case-conflicts";
    description = "Check for files that would conflict in case-insensitive filesystems.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-case-conflict";
    types = [ "file" ];
  };
}
