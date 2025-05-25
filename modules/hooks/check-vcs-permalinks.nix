{ tools, lib, ... }:
{
  config = {
    name = "check-vcs-permalinks";
    description = "Ensure that links to VCS websites are permalinks.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-vcs-permalinks";
    types = [ "text" ];
  };
}