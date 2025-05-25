{ tools, lib, ... }:
{
  config = {
    name = "check-json";
    description = "Check syntax of JSON files.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/check-json";
    types = [ "json" ];
  };
}