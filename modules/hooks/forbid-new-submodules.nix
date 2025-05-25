{ tools, lib, ... }:
{
  config = {
    name = "forbid-new-submodules";
    description = "Prevent addition of new Git submodules.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/forbid-new-submodules";
    types = [ "directory" ];
  };
}