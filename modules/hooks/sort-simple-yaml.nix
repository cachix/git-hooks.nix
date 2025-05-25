{ tools, lib, ... }:
{
  config = {
    name = "sort-simple-yaml";
    description = "Sort simple YAML files.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/sort-simple-yaml";
    files = "\.ya?ml$";
  };
}