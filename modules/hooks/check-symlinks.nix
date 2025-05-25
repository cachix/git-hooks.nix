{ tools, lib, ... }:
{
  config = {
    name = "check-symlinks";
    description = "Find broken symlinks.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-symlinks";
    types = [ "symlink" ];
  };
}