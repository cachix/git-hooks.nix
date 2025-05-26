{ config, tools, lib, ... }:
{
  config = {
    name = "check-vcs-permalinks";
    description = "Ensure that links to VCS websites are permalinks.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-vcs-permalinks";
    types = [ "text" ];
  };
}
