{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/requirements-txt-fixer";
    files = "\\.*(requirements|constraints)\\.*\\.txt$";
  };
}
