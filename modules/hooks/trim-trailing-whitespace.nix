{ tools, lib, ... }:
{
  config = {
    name = "trailing-whitespace";
    description = "Trim trailing whitespace.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/trailing-whitespace-fixer";
    types = [ "text" ];
  };
}