{ tools, lib, ... }:
{
  config = {
    name = "sort-requirements-txt";
    description = "Sort the lines in specified files (defaults to alphabetical).";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/requirements-txt-fixer";
    files = "requirements.*\.txt$";
  };
}