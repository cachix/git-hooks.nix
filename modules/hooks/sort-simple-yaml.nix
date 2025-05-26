{ tools, lib, config, ... }:
{
  config = {
    name = "sort-simple-yaml";
    description = "Sort simple YAML files which consist only of top-level keys, preserving comments and blocks";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/sort-simple-yaml";
    files = "(\\.yaml$)|(\\.yml$)";
  };
}
