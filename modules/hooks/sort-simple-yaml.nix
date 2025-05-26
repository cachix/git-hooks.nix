{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/sort-simple-yaml";
    files = "(\\.yaml$)|(\\.yml$)";
  };
}
