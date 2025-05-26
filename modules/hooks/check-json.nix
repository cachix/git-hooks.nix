{ tools, lib, config, ... }:
{
  config = {
    name = "check-json";
    description = "Check syntax of JSON files.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/check-json";
    types = [ "json" ];
  };
}
