{ tools, lib, config, ... }:
{
  config = {
    name = "sort-requirements-txt";
    description = "Sort requirements in requirements.txt and constraints.txt files";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/requirements-txt-fixer";
    files = "\\.*(requirements|constraints)\\.*\\.txt$";
  };
}
